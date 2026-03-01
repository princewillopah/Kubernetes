import express from 'express';
import { MongoClient } from 'mongodb';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3004;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://mongodb:27017/taskflow';

app.use(cors());
app.use(express.json());

let db;

MongoClient.connect(MONGO_URI).then(client => {
  db = client.db();
  console.log('✅ Analytics Service: Connected to MongoDB');
}).catch(err => console.error('MongoDB error:', err.message));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'analytics-service' });
});

app.post('/api/analytics/track', async (req, res) => {
  try {
    const event = { ...req.body, timestamp: new Date() };
    await db.collection('analytics').insertOne(event);
    console.log('📊 Tracked:', event.eventType);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/analytics', async (req, res) => {
  try {
    const [total, byType] = await Promise.all([
      db.collection('analytics').countDocuments(),
      db.collection('analytics').aggregate([
        { $group: { _id: '$eventType', count: { $sum: 1 } } }
      ]).toArray()
    ]);
    res.json({ success: true, totalEvents: total, eventsByType: byType });
  } catch (error) {
    res.json({ success: true, totalEvents: 0, eventsByType: [] });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Analytics Service on port ${PORT}`);
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
    
    const queue = await channel.assertQueue('analytics', { durable: true });
    await channel.bindQueue(queue.queue, 'taskflow', 'task.*');
    
    channel.consume(queue.queue, async (msg) => {
      if (msg) {
        const data = JSON.parse(msg.content.toString());
        console.log('📊 Tracking event:', data.eventType);
        
        // Store analytic event in MongoDB
        const analytic = {
          eventType: data.eventType,
          taskId: data.data._id || data.data.taskId,
          timestamp: new Date()
        };
        await db.collection('analytics').insertOne(analytic);
        
        channel.ack(msg);
      }
    });
    
    console.log('✅ Analytics Service: Connected to RabbitMQ');
  } catch (error) {
    console.error('❌ RabbitMQ error:', error.message);
  }
}

connectRabbitMQ();
