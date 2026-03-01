#!/bin/bash
echo "🚀 Starting TaskFlow Microservices..."
echo ""
docker-compose down
echo "Building services..."
docker-compose up -d --build
echo ""
echo "⏳ Waiting 30 seconds for services to start..."
sleep 30
echo ""
echo "Initializing database..."
curl -X POST http://localhost:3000/api/init 2>/dev/null
echo ""
echo ""
echo "✅ Ready!"
echo "   Frontend: http://localhost:8080"
echo "   API Gateway: http://localhost:3000"
echo ""
docker-compose ps
