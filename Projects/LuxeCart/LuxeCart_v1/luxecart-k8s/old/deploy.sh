#!/bin/bash
set -e

echo "═══════════════════════════════════════════════════════════"
echo "🚀 LUXECART E-COMMERCE - KUBERNETES DEPLOYMENT"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster."
    echo "   Configure kubectl first: kubectl config use-context <cluster>"
    exit 1
fi

echo "✅ Connected to cluster:"
kubectl cluster-info | head -1

echo ""
read -p "Deploy to this cluster? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Step 1: Creating namespace..."
kubectl apply -f 00-namespace.yaml

echo ""
echo "Step 2: Creating ConfigMap (database schema)..."
kubectl apply -f 01-configmap-db-init.yaml

echo ""
echo "Step 3: Creating Secrets..."
kubectl apply -f 02-secrets.yaml

echo ""
echo "Step 4: Deploying PostgreSQL..."
kubectl apply -f 03-postgres.yaml

echo "   Waiting for PostgreSQL to be ready (may take 2-3 minutes)..."
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=300s || {
    echo "❌ PostgreSQL failed to start"
    echo "Check logs: kubectl logs -l app=postgres -n ecommerce"
    exit 1
}
echo "   ✅ PostgreSQL is ready"

echo ""
echo "Step 5: Deploying Redis..."
kubectl apply -f 04-redis.yaml

echo "   Waiting for Redis to be ready..."
kubectl wait --for=condition=ready pod -l app=redis -n ecommerce --timeout=300s || {
    echo "❌ Redis failed to start"
    exit 1
}
echo "   ✅ Redis is ready"

echo ""
echo "Step 6: Deploying Auth Service (will fix seed passwords)..."
kubectl apply -f 05-auth-service.yaml

echo "   Waiting for Auth Service..."
kubectl wait --for=condition=ready pod -l app=auth-service -n ecommerce --timeout=300s || {
    echo "❌ Auth Service failed to start"
    exit 1
}

echo "   Checking if passwords were fixed..."
sleep 5
kubectl logs -l app=auth-service -n ecommerce | grep "Fixed passwords" && {
    echo "   ✅ Seed user passwords fixed successfully"
} || {
    echo "   ⚠️  Password fix not detected in logs (might still be starting)"
}

echo ""
echo "Step 7: Deploying all microservices..."
kubectl apply -f 06-microservices.yaml

echo ""
echo "Step 8: Deploying API Gateway..."
kubectl apply -f 07-api-gateway.yaml

echo ""
echo "Step 9: Deploying Frontend..."
kubectl apply -f 08-frontend.yaml

echo ""
echo "Step 10: Deploying Ingress..."
kubectl apply -f 09-ingress.yaml

echo ""
echo "Step 11: Deploying Autoscalers..."
kubectl apply -f 10-hpa.yaml

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ DEPLOYMENT COMPLETE!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Waiting for all pods to be ready (this may take a few minutes)..."
kubectl wait --for=condition=ready pod --all -n ecommerce --timeout=600s || {
    echo "⚠️  Some pods are not ready yet"
}

echo ""
echo "📊 DEPLOYMENT STATUS:"
echo "───────────────────────────────────────────────────────────"
kubectl get pods -n ecommerce
echo ""
kubectl get svc -n ecommerce
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "🌐 ACCESS THE APPLICATION:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Option 1: Port Forward (Quick Test)"
echo "   kubectl port-forward svc/frontend 8080:80 -n ecommerce"
echo "   kubectl port-forward svc/api-gateway 3000:3000 -n ecommerce"
echo "   Then open: http://localhost:8080"
echo ""
echo "Option 2: LoadBalancer (if configured)"
echo "   kubectl get svc frontend-loadbalancer -n ecommerce"
echo "   Access at the EXTERNAL-IP shown"
echo ""
echo "Option 3: Ingress (if configured)"
echo "   kubectl get ingress -n ecommerce"
echo "   Access at your configured domain"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🔐 TEST CREDENTIALS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Admin:"
echo "   Email: admin@ecommerce.com"
echo "   Password: 123456"
echo ""
echo "Test Users:"
echo "   john@example.com / 123456"
echo "   jane@example.com / 123456"
echo "   bob@example.com / 123456"
echo "   alice@example.com / 123456"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📝 USEFUL COMMANDS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "View logs:"
echo "   kubectl logs -l app=auth-service -n ecommerce -f"
echo ""
echo "Check all pods:"
echo "   kubectl get pods -n ecommerce"
echo ""
echo "Delete everything:"
echo "   kubectl delete namespace ecommerce"
echo ""
