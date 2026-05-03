#!/bin/bash
# echo "☸️  Deploying TaskFlow to Kubernetes"
# echo ""


kubectl delete pods -n luxe-backend --all
kubectl delete pods -n luxe-frontend --all


Root_DIR="/home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart_v1/luxecart-k8s"
# echo "$Root_DIR/Kubernetes"

echo ""
echo " ================================================================= "
echo "📦 Deploying Backend secrets"
echo " ================================================================= "
# kubectl create namespace taskflow --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f $Root_DIR/Kubernetes/config/ -n luxe-backend

echo ""
echo " ================================================================= "
echo "📦 Deploying Backend Services"
echo " ================================================================= "
SERVICES="analytics-service recommendation-service email-service auth-service user-service product-service cart-service order-service review-service rating-service payment-service notification-service admin-service inventory-service search-service api-gateway-service"

for service in $SERVICES; do
# Set build context for frontend
  dir="$Root_DIR/Kubernetes/backend-services/$service"

  echo "Deploying $service..."
  kubectl apply -f $dir/ -n luxe-backend
  echo ""
done
echo ""
echo " ================================================================= "
echo "📦 Deploying Frontend Services"
echo " ================================================================= "
echo ""
kubectl apply -f $Root_DIR/Kubernetes/frontend/ -n luxe-frontend
echo ""

echo "Waiting 100 seconds for services to initialize..."
for i in {100..1}; do
    printf "\r  ⏳ %02d seconds remaining..." $i
    sleep 1
done
echo ""

echo ""
echo "📊 Status:"
kubectl get pods -n luxe-backend
echo ""
kubectl get services -n luxe-backend
echo ""
kubectl get pods -n luxe-frontend
echo ""
echo ""
kubectl get services -n luxe-frontend
echo ""
echo ""
echo "🌐 Verify and Access the app:"
echo "   kubectl get pods -n luxe-backend"
echo "   kubectl get pods -n luxe-frontend"
echo "   kubectl port-forward service/frontend 80:80 -n luxe-frontend"
























# # BASE_DIR=~/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart_v1/luxecart-k8s/k8s/backend-services

# # for SERVICE_DIR in "$BASE_DIR"/*; do
# #     if [ -d "$SERVICE_DIR" ]; then
# #         SERVICE_NAME=$(basename "$SERVICE_DIR")

# #         echo "Creating manifests for $SERVICE_NAME"
# #         cp deployment.yaml "$SERVICE_DIR/deployment.yaml"
# #         cp service.yaml "$SERVICE_DIR/service.yaml"
# #         # touch "$SERVICE_DIR/deployment.yaml"
# #         # touch "$SERVICE_DIR/service.yaml"
# #         # touch "$SERVICE_DIR/configmap.yaml"
# #         # touch "$SERVICE_DIR/secret.yaml"

# #     fi
# # done

# # echo "All Kubernetes manifest files created successfully."