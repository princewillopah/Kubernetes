import express from 'express';
import http from 'http';
import cors from 'cors';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']
}));

// Parse JSON for incoming requests
// app.use(express.json());

const services = {
  task: 'http://task-service:3001',
  user: 'http://user-service:3002',
  notification: 'http://notification-service:3003',
  analytics: 'http://analytics-service:3004'
};

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'api-gateway' });
});

// Simple direct proxy
function proxyRequest(req, res, targetUrl) {
  console.log(`→ ${req.method} ${req.url}`);

  const options = {
    method: req.method,
    headers: {
      ...req.headers,
      host: new URL(targetUrl).host
    }
  };

  const proxyReq = http.request(targetUrl, options, (proxyRes) => {
    console.log(`← ${proxyRes.statusCode} ${targetUrl}`);
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    console.error('Gateway proxy error:', err.message);
    if (!res.headersSent) {
      res.status(503).json({ error: 'Service unavailable' });
    }
  });

  // Stream request body directly
  req.pipe(proxyReq);
}


// Routes
app.all('/api/tasks*', (req, res) => {
  proxyRequest(req, res, services.task + req.url);
});

app.all('/api/items*', (req, res) => {
  const newUrl = req.url.replace('/api/items', '/api/tasks');
  proxyRequest(req, res, services.task + newUrl);
});

app.all('/api/stats', (req, res) => {
  proxyRequest(req, res, services.task + '/api/tasks/stats');
});

app.all('/api/init', (req, res) => {
  proxyRequest(req, res, services.task + '/api/tasks/init');
});

app.all('/api/users*', (req, res) => {
  proxyRequest(req, res, services.user + req.url);
});

app.all('/api/notifications*', (req, res) => {
  proxyRequest(req, res, services.notification + req.url);
});

app.all('/api/analytics*', (req, res) => {
  proxyRequest(req, res, services.analytics + req.url);
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ API Gateway on port ${PORT}`);
});
