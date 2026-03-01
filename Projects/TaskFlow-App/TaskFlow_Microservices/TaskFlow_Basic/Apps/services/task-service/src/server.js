import express from 'express';
import { MongoClient, ObjectId } from 'mongodb';
import { createClient } from 'redis';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3001;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://mongodb:27017/taskflow';
const REDIS_HOST = process.env.REDIS_HOST || 'redis';
const REDIS_PORT = process.env.REDIS_PORT || 6379;

// CORS first
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
}));

app.use(express.json());

// ---------- LOGGING ----------
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`);
  next();
});

let db;
let mongoConnected = false;
let redisClient;

// ---------- MONGO ----------
async function connectMongo() {
  try {
    const client = await MongoClient.connect(MONGO_URI);
    db = client.db();
    mongoConnected = true;
    console.log('✅ Task Service: Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB error:', error.message);
    mongoConnected = false;
    setTimeout(connectMongo, 5000);
  }
}
// ---------- REDIS ----------
async function connectRedis() {
  try {
    redisClient = createClient({ socket: { host: REDIS_HOST, port: REDIS_PORT } });
    redisClient.on('error', err => console.error('Redis error:', err.message));
    await redisClient.connect();
    console.log('✅ Task Service: Connected to Redis');
  } catch (error) {
    console.error('❌ Redis error:', error.message);
  }
}

connectMongo();
connectRedis();
// ---------- HEALTH ----------
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'task-service', 
    timestamp: new Date(),
    mongo: mongoConnected ? 'connected' : 'disconnected'
  });
});
// ---------- GUARD ----------
function dbGuard(res){
  if(!mongoConnected || !db){
    res.status(503).json({success:false,error:'Database not ready'});
    return false;
  }
  return true;
}


// Stats route - MUST be before /:id
app.get('/api/tasks/stats', async (req, res) => {
  try {
    if (!mongoConnected || !db) {
      return res.status(503).json({ error: 'Database not ready' });
    }
    
    const [total, categories, statuses] = await Promise.all([
      db.collection('tasks').countDocuments(),
      db.collection('tasks').aggregate([{ $group: { _id: '$category', count: { $sum: 1 } } }]).toArray(),
      db.collection('tasks').aggregate([{ $group: { _id: '$status', count: { $sum: 1 } } }]).toArray()
    ]);
    
    console.log('✅ Stats retrieved');
    res.json({ success: true, totalItems: total, categories, statusStats: statuses });
  } catch (error) {
    console.error('Stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Init route - MUST be before /:id
app.post('/api/tasks/init', async (req, res) => {
  try {
    if (!mongoConnected || !db) {
      return res.status(503).json({ error: 'Database not ready' });
    }
    
    const count = await db.collection('tasks').countDocuments();
    if (count === 0) {
      await db.collection('tasks').insertMany([
        { name: "Welcome to TaskFlow!", description: "Working microservices", category: "work", priority: "medium", status: "not-started", color: "#6366f1", createdAt: new Date(), updatedAt: new Date() },
        { name: "Test Task", description: "Everything works!", category: "work", priority: "high", status: "in-progress", color: "#10b981", createdAt: new Date(), updatedAt: new Date() }
      ]);
    }
    console.log('✅ Database initialized');
    res.json({ success: true, message: 'Initialized' });
  } catch (error) {
    console.error('Init error:', error);
    res.status(500).json({ error: error.message });
  }
});

// CREATE task
app.post('/api/tasks', async (req, res) => {
  console.log('📝 Creating task:', req.body);
  
  try {
    if (!mongoConnected || !db) {
      console.error('❌ Database not connected');
      return res.status(503).json({ success: false, error: 'Database not ready' });
    }
    
    const task = {
      name: req.body.name || 'Untitled',
      description: req.body.description || '',
      status: req.body.status || 'not-started',
      priority: req.body.priority || 'medium',
      category: req.body.category || 'work',
      color: req.body.color || '#6366f1',
      createdAt: new Date(),
      updatedAt: new Date()
    };
    
    const result = await db.collection('tasks').insertOne(task);
    const createdTask = { _id: result.insertedId, ...task };
    
    console.log('✅ Task created:', result.insertedId);
    res.status(201).json({ success: true, task: createdTask, item: createdTask });
  } catch (error) {
    console.error('❌ Create error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET all tasks
app.get('/api/tasks', async (req, res) => {
  try {
    if (!mongoConnected || !db) {
      return res.status(503).json({ error: 'Database not ready' });
    }
    
    const { category, status, search } = req.query;
    let query = {};
    if (category && category !== 'all') query.category = category;
    if (status && status !== 'all') query.status = status;
    if (search) query.$or = [
      { name: { $regex: search, $options: 'i' } },
      { description: { $regex: search, $options: 'i' } }
    ];
    
    const tasks = await db.collection('tasks').find(query).sort({ createdAt: -1 }).toArray();
    const total = await db.collection('tasks').countDocuments();
    
    console.log(`✅ Retrieved ${tasks.length} tasks`);
    res.json({ success: true, items: tasks, count: tasks.length, total });
  } catch (error) {
    console.error('Get tasks error:', error);
    res.status(500).json({ error: error.message });
  }
});

// GET single task - MUST be after specific routes
app.get('/api/tasks/:id', async (req, res) => {
  try {
    if (!ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ error: 'Invalid ID' });
    }
    
    if (!mongoConnected || !db) {
      return res.status(503).json({ error: 'Database not ready' });
    }
    
    const task = await db.collection('tasks').findOne({ _id: new ObjectId(req.params.id) });
    if (!task) return res.status(404).json({ error: 'Not found' });
    
    res.json({ success: true, item: task });
  } catch (error) {
    console.error('Get task error:', error);
    res.status(500).json({ error: error.message });
  }
});

// UPDATE task
app.put('/api/tasks/:id', async (req, res) => {
  console.log('✏️ Updating task:', req.params.id);
  
  try {
    if (!ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ error: 'Invalid ID' });
    }
    
    if (!mongoConnected || !db) {
      return res.status(503).json({ error: 'Database not ready' });
    }
    
    const updates = { ...req.body };
    delete updates._id;
    delete updates.createdAt;
    updates.updatedAt = new Date();
    
    if (updates.status === 'completed') {
      updates.completedAt = new Date();
    } else {
      updates.completedAt = null;
    }
    
    const result = await db.collection('tasks').updateOne(
      { _id: new ObjectId(req.params.id) },
      { $set: updates }
    );
    
    if (result.matchedCount === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }
    
    const task = await db.collection('tasks').findOne({ _id: new ObjectId(req.params.id) });
    
    console.log('✅ Task updated:', req.params.id);
    res.json({ success: true, item: task });
  } catch (error) {
    console.error('❌ Update error:', error);
    res.status(500).json({ error: error.message });
  }
});

// DELETE task
app.delete('/api/tasks/:id', async (req, res) => {
  console.log('🗑️ Deleting task:', req.params.id);
  
  try {
    if (!ObjectId.isValid(req.params.id)) {
      return res.status(400).json({ error: 'Invalid ID' });
    }
    
    if (!mongoConnected || !db) {
      return res.status(503).json({ error: 'Database not ready' });
    }
    
    const result = await db.collection('tasks').deleteOne({ _id: new ObjectId(req.params.id) });
    
    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }
    
    console.log('✅ Task deleted:', req.params.id);
    res.json({ success: true, message: 'Deleted' });
  } catch (error) {
    console.error('❌ Delete error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Task Service on port ${PORT}`);
});
