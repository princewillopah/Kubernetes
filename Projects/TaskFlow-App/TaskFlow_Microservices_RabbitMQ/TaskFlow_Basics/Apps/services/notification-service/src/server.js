import express from 'express';
import { createClient } from 'redis';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3003;
const REDIS_HOST = process.env.REDIS_HOST || 'redis';

app.use(cors());
app.use(express.json());

let redisClient;

async function connectRedis() {
  try {
    redisClient = createClient({ socket: { host: REDIS_HOST, port: 6379 } });
    await redisClient.connect();
    console.log('✅ Notification Service: Connected to Redis');
  } catch (error) {
    console.error('Redis error:', error.message);
  }
}

connectRedis();

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'notification-service' });
});

app.post('/api/notifications/send', async (req, res) => {
  try {
    const notification = { ...req.body, timestamp: new Date() };
    if (redisClient?.isOpen) {
      await redisClient.lPush('notifications', JSON.stringify(notification));
      await redisClient.lTrim('notifications', 0, 99);
    }
    console.log('📬 Notification:', notification.message);
    res.json({ success: true, notification });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/notifications', async (req, res) => {
  try {
    const notifications = await redisClient.lRange('notifications', 0, 19);
    res.json({ success: true, notifications: notifications.map(n => JSON.parse(n)) });
  } catch (error) {
    res.json({ success: true, notifications: [] });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Notification Service on port ${PORT}`);
});

// Connect to RabbitMQ and consume events
async function connectRabbitMQ() {
  const RABBITMQ_URL = process.env.RABBITMQ_URL;
  if (!RABBITMQ_URL) {
    console.log('⚠️ RabbitMQ URL not provided');
    return;
  }
  
  try {
    const connection = await import('amqplib').then(m => m.connect(RABBITMQ_URL));
    const channel = await connection.createChannel();
    await channel.assertExchange('taskflow', 'topic', { durable: true });
    
    const queue = await channel.assertQueue('notifications', { durable: true });
    await channel.bindQueue(queue.queue, 'taskflow', 'task.*');
    
    channel.consume(queue.queue, async (msg) => {
      if (msg) {
        const data = JSON.parse(msg.content.toString());
        console.log('📬 Received event:', data.eventType);
        
        // Store notification in Redis
        if (redisClient?.isOpen) {
          const notification = {
            type: data.eventType,
            taskId: data.data._id || data.data.taskId,
            taskName: data.data.name || 'Unknown',
            timestamp: new Date()
          };
          await redisClient.lPush('notifications', JSON.stringify(notification));
          await redisClient.lTrim('notifications', 0, 99);
        }
        
        channel.ack(msg);
      }
    });
    
    console.log('✅ Notification Service: Connected to RabbitMQ');
  } catch (error) {
    console.error('❌ RabbitMQ error:', error.message);
  }
}

connectRabbitMQ();
