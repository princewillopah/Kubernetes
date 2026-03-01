#!/bin/bash
echo "☸️  Deploying TaskFlow to Kubernetes"
echo ""



echo ""
echo "☸️  Deploying to Kubernetes..."
kubectl create namespace taskflow --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f k8s/secrets/ -n taskflow
kubectl apply -f k8s/configmaps/ -n taskflow
kubectl apply -f k8s/deployments/mongodb.yaml -n taskflow
kubectl apply -f k8s/deployments/redis.yaml -n taskflow
echo ""

echo "⏳ Waiting for databases..."
kubectl wait --for=condition=ready pod -l app=mongodb -n taskflow --timeout=120s
echo ""
echo "⏳ Waiting for redis..."
kubectl wait --for=condition=ready pod -l app=redis -n taskflow --timeout=120s
echo ""
echo "⏳ deploying services..."
kubectl apply -f k8s/deployments/ -n taskflow


echo ""
echo "✅ Deployment complete!"
echo "waiting for services to be ready..."
kubectl wait --for=condition=ready pod -l app=task-service -n taskflow --timeout=120s
kubectl wait --for=condition=ready pod -l app=user-service -n taskflow --timeout=120s
kubectl wait --for=condition=ready pod -l app=notification-service -n taskflow --timeout=120s
kubectl wait --for=condition=ready pod -l app=analytics-service -n taskflow --timeout=120s
kubectl wait --for=condition=ready pod -l app=api-gateway -n taskflow --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend -n taskflow --timeout=120s

echo ""
echo "📊 Status:"
kubectl get pods -n taskflow
echo ""
kubectl get services -n taskflow
echo ""
echo "🌐 Access the app:"
echo "   kubectl port-forward service/frontend 80:80 -n taskflow"
