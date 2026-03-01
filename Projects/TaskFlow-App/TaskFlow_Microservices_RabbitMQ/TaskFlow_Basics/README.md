# TaskFlow Microservices V2 - WITH RABBITMQ (ALL BUGS FIXED)

## ✅ All Fixes Applied

This version includes ALL the bug fixes:

1. **Button Enable Bug** - Button re-enables after every save
2. **Delete Issue** - Removed express.json() from API Gateway, using request streaming
3. **Progress Bar** - Shows 65% on in-progress tasks
4. **Button Text** - Resets correctly (Create Task / Update Task)
5. **Nginx Caching** - Completely disabled
6. **RabbitMQ Integration** - Event-driven architecture working

## 🏗️ Architecture

**5 Microservices + RabbitMQ:**

- **Task Service** (3001) - Publishes events to RabbitMQ
- **User Service** (3002) - Authentication
- **Notification Service** (3003) - Consumes task events
- **Analytics Service** (3004) - Consumes task events  
- **API Gateway** (3000) - Routes requests
- **RabbitMQ** (5672, 15672) - Message broker

**Event Flow:**
```
Create Task → Task Service → MongoDB ✅
                             ↓
                           RabbitMQ
                             ↓
              ┌──────────────┴───────────────┐
              ↓                              ↓
    Notification Service           Analytics Service
    (stores in Redis)              (tracks in MongoDB)
```

## 🚀 Quick Start

```bash
docker-compose up -d --build

# Wait 45 seconds (RabbitMQ takes longer to start)
sleep 45

# Access
open http://localhost:8080
```

## 📊 Access Points

- **Frontend**: http://localhost:8080
- **API Gateway**: http://localhost:3000
- **RabbitMQ Management**: http://localhost:15672
  - Username: `taskflow`
  - Password: `taskflow2024`
- **MongoDB**: localhost:27017
- **Redis**: localhost:6379

## 🎯 Monitor RabbitMQ Events

Visit: http://localhost:15672

1. Login with credentials above
2. Go to "Exchanges" tab
3. Click on "taskflow" exchange
4. See event routing keys:
   - `task.created`
   - `task.updated`
   - `task.deleted`

## ✅ Features Working

- ✅ Create multiple tasks (button works every time!)
- ✅ Update multiple tasks (button works every time!)
- ✅ Delete tasks (streaming proxy works!)
- ✅ Progress bars on in-progress tasks
- ✅ Real-time stats updates
- ✅ RabbitMQ event publishing
- ✅ Notification service consuming events
- ✅ Analytics service tracking events

## 🛑 Stop

```bash
docker-compose down
```

## ☸️ Kubernetes Ready

All K8s manifests in `k8s/` folder including RabbitMQ StatefulSet.

Perfect for learning event-driven microservices! 🎉
