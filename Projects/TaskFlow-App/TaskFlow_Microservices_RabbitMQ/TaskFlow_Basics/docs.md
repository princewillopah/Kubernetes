# TaskFlow Microservices V2 - WITH RABBITMQ (ALL BUGS FIXED)


```
┌─────────────────────────────────────────────────────────────┐
│                         BROWSER                             │
│                    http://localhost:8080                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ HTTP Requests
                           ↓
                    ┌──────────────┐
                    │    NGINX     │ Port 8080
                    │  (Frontend)  │ Serves HTML/CSS/JS
                    └──────┬───────┘
                           │
                           │ /api/* requests proxied to →
                           ↓
                    ┌──────────────┐
                    │ API GATEWAY  │ Port 3000
                    │              │ Routes all requests
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┬──────────────┐
        │                  │                  │              │
        ↓                  ↓                  ↓              ↓
┌───────────────┐  ┌───────────────┐  ┌──────────────┐  ┌──────────────-┐
│ TASK SERVICE  │  │ USER SERVICE  │  │ NOTIFICATION │  │  ANALYTICS    │
│   Port 3001   │  │   Port 3002   │  │   SERVICE    │  │   SERVICE     │
│               │  │               │  │   Port 3003  │  │   Port 3004   │
│ 📤 PUBLISHER │   │               │ |📥 CONSUMER   │  │ 📥 CONSUMER   │
└───┬───────┬───┘  └───────┬───────┘  └──────┬───────┘  └─────-─┬───────┘
    │       │              │                  │                 │
    │       └──────────────┼──────────────────┼─────────────────┘
    │                      │                  │                 │
    │       ┌──────────────┼──────────────────┘                 │
    │       │              │                                    │
    │       │              ↓                                    │
    │   ┌───▼──────────────────────────┐                        │
    │   │       RABBITMQ               │                        │
    │   │  Port 5672 (AMQP)            │                        │
    │   │  Port 15672 (Management UI)  │                        │
    │   │                              │                        │
    │   │  Exchange: "taskflow"        │                        │
    │   │  Queues:                     │                        │
    │   │   - notifications            │                        │
    │   │   - analytics                │                        │
    │   └──────────────────────────────┘                        │
    │                                                           │
    ↓                                                           ↓
┌─────────┐                                                ┌─────────┐
│ MongoDB │                                                │ MongoDB │
│  27017  │                                                │  27017  │
└─────────┘                                                └─────────┘
     +                                                          
┌─────────┐                                                     
│  Redis  │                                                     
│  6379   │                                                     
└─────────┘

```

### 📡 HOW THEY COMMUNICATE
1. Browser → Nginx (Frontend)
    - Protocol: HTTP
    - What: Browser requests HTML, CSS, JavaScript files
    - Example: GET http://localhost:8080/index.html

2. Browser → Nginx → API Gateway
    - Protocol: HTTP (proxied)
    - What: API calls from frontend JavaScript

Example:
```
  Browser: POST http://localhost:8080/api/items
  Nginx: Forwards to → http://api-gateway:3000/api/items
  ```
3. API Gateway → Services

Protocol: HTTP (Internal Docker Network)
What: Gateway routes requests to appropriate service
Example:

javascript  // Request comes in to gateway
  POST /api/items
  
  // Gateway routes to Task Service
  → http://task-service:3001/api/tasks
4. Services → Databases

Protocol:

MongoDB: MongoDB Wire Protocol (port 27017)
Redis: RESP (Redis Protocol, port 6379)


What: Services store/retrieve data
Example:

javascript  // Task Service saves task
  await db.collection('tasks').insertOne(task);
5. Task Service → RabbitMQ (V2 Only)

Protocol: AMQP (Advanced Message Queue Protocol)
Port: 5672
What: Publishes events when tasks are created/updated/deleted
Example:

javascript  // Task created - publish event
  rabbitChannel.publish(
    'taskflow',           // Exchange name
    'task.created',       // Routing key
    Buffer.from(JSON.stringify({
      eventType: 'created',
      data: task
    }))
  );
6. RabbitMQ → Notification/Analytics Services (V2 Only)

Protocol: AMQP
What: Services consume events from their queues
Example:

javascript  // Notification Service consumes events
  channel.consume('notifications', (msg) => {
    const event = JSON.parse(msg.content);
    console.log('Received event:', event.eventType);
    // Store notification in Redis
  });
```

## 🔄 **COMPLETE REQUEST FLOW EXAMPLES**

### **Example 1: Create a Task (V1 - No RabbitMQ)**
```
1. User clicks "Create Task" in browser
   ↓
2. JavaScript sends: POST http://localhost:8080/api/items
   ↓
3. Nginx receives and proxies to: http://api-gateway:3000/api/items
   ↓
4. API Gateway routes to: http://task-service:3001/api/tasks
   ↓
5. Task Service:
   - Saves task to MongoDB
   - Caches in Redis
   - Returns response
   ↓
6. Response flows back: Task Service → API Gateway → Nginx → Browser
   ↓
7. Browser JavaScript updates the UI
```

### **Example 2: Create a Task (V2 - With RabbitMQ)**
```
1. User clicks "Create Task" in browser
   ↓
2. JavaScript sends: POST http://localhost:8080/api/items
   ↓
3. Nginx receives and proxies to: http://api-gateway:3000/api/items
   ↓
4. API Gateway routes to: http://task-service:3001/api/tasks
   ↓
5. Task Service:
   - Saves task to MongoDB
   - Caches in Redis
   - 📤 Publishes event to RabbitMQ:
     {
       exchange: 'taskflow',
       routingKey: 'task.created',
       data: {task details}
     }
   - Returns response
   ↓
6. Response flows back: Task Service → API Gateway → Nginx → Browser
   ↓
7. Meanwhile, RabbitMQ distributes event to:
   - Notification Service queue
   - Analytics Service queue
   ↓
8. Notification Service 📥:
   - Receives event
   - Stores notification in Redis
   ↓
9. Analytics Service 📥:
   - Receives event
   - Tracks event in MongoDB
   ↓
10. Browser JavaScript updates the UI


## 🌐 **DOCKER NETWORK**

All services communicate on a **Docker Bridge Network** called `taskflow-network`:
```
172.19.0.0/16 (example IP range)

├── 172.19.0.2 → MongoDB
├── 172.19.0.3 → Redis
├── 172.19.0.4 → RabbitMQ (V2 only)
├── 172.19.0.5 → Task Service
├── 172.19.0.6 → User Service
├── 172.19.0.7 → Notification Service
├── 172.19.0.8 → Analytics Service
├── 172.19.0.9 → API Gateway
└── 172.19.0.10 → Nginx (Frontend)
```
Services find each other using Docker DNS:

http://task-service:3001 (Docker resolves this)
`mongodb://mongodb:27017` (Docker resolves this)
redis://redis:6379 (Docker resolves this)

#### 📊 PORT MAPPINGS
Exposed to Host (Your Computer):

     - 8080 → Nginx (Frontend)
     - 3000 → API Gateway
     - 3001 → Task Service
     - 3002 → User Service
     - 3003 → Notification Service
     - 3004 → Analytics Service
     - 27017 → MongoDB
     - 6379 → Redis
     - 5672 → RabbitMQ AMQP (V2 only)
     - 15672 → RabbitMQ Management UI (V2 only)