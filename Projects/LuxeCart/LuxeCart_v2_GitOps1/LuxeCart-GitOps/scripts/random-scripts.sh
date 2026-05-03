# ======================================================================================

# # #!/bin/bash
# # set -e

# # REGISTRY_NAME="princewillopah2"
# # backend_image="$REGISTRY_NAME/taskflow-app_backend"
# # frontend_image="$REGISTRY_NAME/taskflow-app_frontend"
# # image_tag="v-1.1.6"
# # current_dir=$(pwd)





# # REGISTRY_NAME="princewillopah2" # Change this to your DockerHub username or registry URL if using a different registry
# # APP_NAME="taskflow-micro-services"
# # image_tag="1.0.0"
# # current_dir=$(pwd)

# # # Login to DockerHub
# # echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

# # echo ""
# # echo " ================================================================= "
# # echo "📦 Building and pushing images to $REGISTRY_NAME..."
# # echo " ================================================================= "
# # SERVICES="analytics-service recommendation-service email-service auth-service user-service product-service cart-service order-service review-service rating-service payment-service notification-service admin-service inventory-service search-service api-gateway-service frontend"

# # for service in $SERVICES; do
# # # Set build context for frontend
# #   dir="./applications/services/$service"
# #   if [ "$service" == "frontend" ]; then
# #     dir="./applications/frontend"
# #   fi


# #   echo "Building $service..."
# #   docker build -t $REGISTRY/$APP_NAME-$service:$image_tag $dir
# #   docker push $REGISTRY/$APP_NAME-$service:$image_tag
# #   echo ""
# # done


# # echo "✅ Services are completely built and pushed to DockerHub"
# # echo ""
# # echo "Copy the following to kubernetes yaml files"
# # echo "------------------------------------------------------------------"
# # for service in $SERVICES; do
# #   echo "$REGISTRY/$APP_NAME-$service:$image_tag"
# # done






















# # # curl -X POST \
# # #   https://hub.docker.com/v2/repositories/ \
# # #   -H 'Content-Type: application/json' \
# # #   -H "Authorization: Bearer $(echo $DOCKER_PASSWORD2 | docker login -u $DOCKER_USERNAME2 --password-stdin | grep -o 'token=.*')" \
# # #   -d '{"name": "taskflow-app/backend", "description": "My repo"}'


# # # # Login to DockerHub
# # # echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

# # # echo " ================================================================= "
# # # echo " Build backend image "
# # # echo " ================================================================= "
# # # docker build -t $backend_image:$image_tag $current_dir/backend

# # # echo " ================================================================= "
# # # echo " Push Backend image to Dockerhub "
# # # echo " ================================================================= "
# # # docker push $backend_image:$image_tag

# # # echo ""
# # # echo " ================================================================= "
# # # echo " Build frontend image "
# # # echo " ================================================================= "
# # # docker build -t $frontend_image:$image_tag $current_dir/frontend

# # # echo " ================================================================= "
# # # echo " Push Frontend image to Dockerhub "
# # # echo " ================================================================= "
# # # docker push $frontend_image:$image_tag

# # # echo ""
# # # echo "copy the following to kubernetes yaml files"
# # # echo "$frontend_image:$image_tag"
# # # echo "$backend_image:$image_tag"






























# # # BASE_DIR=~/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart_v1/luxecart-k8s/services

# # # for SERVICE_DIR in "$BASE_DIR"/*; do
# # #     if [ -d "$SERVICE_DIR" ]; then
# # #         SERVICE_NAME=$(basename "$SERVICE_DIR")

# # #         echo "Creating manifests for $SERVICE_NAME"

# # #         touch "$SERVICE_DIR/deployment.yaml"
# # #         touch "$SERVICE_DIR/service.yaml"
# # #         touch "$SERVICE_DIR/configmap.yaml"
# # #         touch "$SERVICE_DIR/secret.yaml"

# # #     fi
# # # done

# # # echo "All Kubernetes manifest files created successfully."

# # # #!/bin/bash
# # # set -e

# # # REGISTRY_NAME="princewillopah2"
# # # backend_image="$REGISTRY_NAME/taskflow-app_backend"
# # # frontend_image="$REGISTRY_NAME/taskflow-app_frontend"
# # # image_tag="v-1.1.6"
# # # current_dir=$(pwd)





# # # REGISTRY_NAME="princewillopah2" # Change this to your DockerHub username or registry URL if using a different registry
# # # APP_NAME="luxecart"
# # # image_tag="1.0.0"
# # # current_dir=$(pwd)

# # # # Login to DockerHub
# # # echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

# # # echo ""
# # # echo " ================================================================= "
# # # echo "📦 Building and pushing images to $REGISTRY_NAME..."
# # # echo " ================================================================= "
# # # SERVICES="analytics-service recommendation-service email-service auth-service user-service product-service cart-service order-service review-service rating-service payment-service notification-service admin-service inventory-service search-service api-gateway-service frontend"

# # # for service in $SERVICES; do
# # # # Set build context for frontend
# # #   dir="./application/services/$service"
# # #   if [ "$service" == "frontend" ]; then
# # #     dir="./application/frontend"
# # #   fi


# # #   echo "Building $service..."
# # #   docker build -t $REGISTRY_NAME/$APP_NAME-$service:$image_tag $dir
# # #   docker push $REGISTRY_NAME/$APP_NAME-$service:$image_tag
# # #   echo ""
# # # done


# # # echo "✅ Services are completely built and pushed to DockerHub"
# # # echo ""
# # # echo "Copy the following to kubernetes yaml files"
# # # echo "------------------------------------------------------------------"
# # # for service in $SERVICES; do
# # #   echo "$REGISTRY_NAME/$APP_NAME-$service:$image_tag"
# # # done






















# # # curl -X POST \
# # #   https://hub.docker.com/v2/repositories/ \
# # #   -H 'Content-Type: application/json' \
# # #   -H "Authorization: Bearer $(echo $DOCKER_PASSWORD2 | docker login -u $DOCKER_USERNAME2 --password-stdin | grep -o 'token=.*')" \
# # #   -d '{"name": "taskflow-app/backend", "description": "My repo"}'


# # # # Login to DockerHub
# # # echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

# # # echo " ================================================================= "
# # # echo " Build backend image "
# # # echo " ================================================================= "
# # # docker build -t $backend_image:$image_tag $current_dir/backend

# # # echo " ================================================================= "
# # # echo " Push Backend image to Dockerhub "
# # # echo " ================================================================= "
# # # docker push $backend_image:$image_tag

# # # echo ""
# # # echo " ================================================================= "
# # # echo " Build frontend image "
# # # echo " ================================================================= "
# # # docker build -t $frontend_image:$image_tag $current_dir/frontend

# # # echo " ================================================================= "
# # # echo " Push Frontend image to Dockerhub "
# # # echo " ================================================================= "
# # # docker push $frontend_image:$image_tag

# # # echo ""
# # # echo "copy the following to kubernetes yaml files"
# # # echo "$frontend_image:$image_tag"
# # # echo "$backend_image:$image_tag"

# # # =================================================================================================

# # #!/bin/bash
# # echo "☸️  Deploying TaskFlow to Kubernetes"
# # echo ""



# # echo ""
# # echo "☸️  Deploying to Kubernetes..."
# # kubectl create namespace taskflow --dry-run=client -o yaml | kubectl apply -f -
# # kubectl apply -f k8s/secrets/ -n taskflow
# # kubectl apply -f k8s/configmaps/ -n taskflow
# # kubectl apply -f k8s/deployments/mongodb.yaml -n taskflow
# # kubectl apply -f k8s/deployments/redis.yaml -n taskflow
# # echo ""

# # echo "⏳ Waiting for databases..."
# # kubectl wait --for=condition=ready pod -l app=mongodb -n taskflow --timeout=120s
# # echo ""
# # echo "⏳ Waiting for redis..."
# # kubectl wait --for=condition=ready pod -l app=redis -n taskflow --timeout=120s
# # echo ""
# # echo "⏳ deploying services..."
# # kubectl apply -f k8s/deployments/ -n taskflow


# # echo ""
# # echo "✅ Deployment complete!"
# # echo "waiting for services to be ready..."
# # kubectl wait --for=condition=ready pod -l app=task-service -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=user-service -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=notification-service -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=analytics-service -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=api-gateway -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=frontend -n taskflow --timeout=120s

# # echo ""
# # echo "📊 Status:"
# # kubectl get pods -n taskflow
# # echo ""
# # kubectl get services -n taskflow
# # echo ""
# # echo "🌐 Access the app:"
# # echo "   kubectl port-forward service/frontend 80:80 -n taskflow"


# # # =================================================================================================
























# # # BASE_DIR=~/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart_v1/luxecart-k8s/k8s/backend-services

# # # for SERVICE_DIR in "$BASE_DIR"/*; do
# # #     if [ -d "$SERVICE_DIR" ]; then
# # #         SERVICE_NAME=$(basename "$SERVICE_DIR")

# # #         echo "Creating manifests for $SERVICE_NAME"
# # #         cp deployment.yaml "$SERVICE_DIR/deployment.yaml"
# # #         cp service.yaml "$SERVICE_DIR/service.yaml"
# # #         # touch "$SERVICE_DIR/deployment.yaml"
# # #         # touch "$SERVICE_DIR/service.yaml"
# # #         # touch "$SERVICE_DIR/configmap.yaml"
# # #         # touch "$SERVICE_DIR/secret.yaml"

# # #     fi
# # # done

# # # echo "All Kubernetes manifest files created successfully."

# # #!/bin/bash
# # set -e

# # REGISTRY_NAME="princewillopah2"
# # backend_image="$REGISTRY_NAME/taskflow-app_backend"
# # frontend_image="$REGISTRY_NAME/taskflow-app_frontend"
# # image_tag="v-1.1.6"
# # current_dir=$(pwd)





# # REGISTRY_NAME="princewillopah2" # Change this to your DockerHub username or registry URL if using a different registry
# # APP_NAME="luxecart"
# # image_tag="1.0.0"
# # current_dir=$(pwd)

# # # Login to DockerHub
# # echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

# # echo ""
# # echo " ================================================================= "
# # echo "📦 Building and pushing images to $REGISTRY_NAME..."
# # echo " ================================================================= "
# # SERVICES="analytics-service recommendation-service email-service auth-service user-service product-service cart-service order-service review-service rating-service payment-service notification-service admin-service inventory-service search-service api-gateway-service frontend"

# # for service in $SERVICES; do
# # # Set build context for frontend
# #   dir="./application/services/$service"
# #   if [ "$service" == "frontend" ]; then
# #     dir="./application/frontend"
# #   fi


# #   echo "Building $service..."
# #   docker build -t $REGISTRY_NAME/$APP_NAME-$service:$image_tag $dir
# #   docker push $REGISTRY_NAME/$APP_NAME-$service:$image_tag
# #   echo ""
# # done


# # echo "✅ Services are completely built and pushed to DockerHub"
# # echo ""
# # echo "Copy the following to kubernetes yaml files"
# # echo "------------------------------------------------------------------"
# # for service in $SERVICES; do
# #   echo "$REGISTRY_NAME/$APP_NAME-$service:$image_tag"
# # done






















# # curl -X POST \
# #   https://hub.docker.com/v2/repositories/ \
# #   -H 'Content-Type: application/json' \
# #   -H "Authorization: Bearer $(echo $DOCKER_PASSWORD2 | docker login -u $DOCKER_USERNAME2 --password-stdin | grep -o 'token=.*')" \
# #   -d '{"name": "taskflow-app/backend", "description": "My repo"}'


# # # Login to DockerHub
# # echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

# # echo " ================================================================= "
# # echo " Build backend image "
# # echo " ================================================================= "
# # docker build -t $backend_image:$image_tag $current_dir/backend

# # echo " ================================================================= "
# # echo " Push Backend image to Dockerhub "
# # echo " ================================================================= "
# # docker push $backend_image:$image_tag

# # echo ""
# # echo " ================================================================= "
# # echo " Build frontend image "
# # echo " ================================================================= "
# # docker build -t $frontend_image:$image_tag $current_dir/frontend

# # echo " ================================================================= "
# # echo " Push Frontend image to Dockerhub "
# # echo " ================================================================= "
# # docker push $frontend_image:$image_tag

# # echo ""
# # echo "copy the following to kubernetes yaml files"
# # echo "$frontend_image:$image_tag"
# # echo "$backend_image:$image_tag"

# # =================================================================================================

# #!/bin/bash
# echo "☸️  Deploying TaskFlow to Kubernetes"
# echo ""



# echo ""
# echo " ================================================================= "
# echo "📦 Deploying Backend secrets"
# echo " ================================================================= "
# # kubectl create namespace taskflow --dry-run=client -o yaml | kubectl apply -f -
# kubectl apply -f config/ -n luxe-backend

# echo ""
# echo " ================================================================= "
# echo "📦 Deploying Backend Services"
# echo " ================================================================= "
# SERVICES="analytics-service recommendation-service email-service auth-service user-service product-service cart-service order-service review-service rating-service payment-service notification-service admin-service inventory-service search-service api-gateway-service frontend"

# for service in $SERVICES; do
# # Set build context for frontend
#   dir="./backend-services/$service"

#   echo "Building $service..."
#   kubectl apply -f $dir/ -n luxe-backend
#   echo ""
# done
# echo ""
# echo " ================================================================= "
# echo "📦 Deploying Frontend Services"
# echo " ================================================================= "
# echo ""
# kubectl apply -f frontend/ -n luxe-frontend
# echo ""



# echo "Waiting 100 seconds for services to initialize..."
# for i in {100..1}; do
#     printf "\r  ⏳ %02d seconds remaining..." $i
#     sleep 1
# done
# echo ""
# # echo "⏳ Waiting for databases..."
# # kubectl wait --for=condition=ready pod -l app=mongodb -n taskflow --timeout=120s
# # echo ""
# # echo "⏳ Waiting for redis..."
# # kubectl wait --for=condition=ready pod -l app=redis -n taskflow --timeout=120s
# # echo ""
# # echo "⏳ deploying services..."
# # kubectl apply -f k8s/deployments/ -n taskflow


# # echo ""
# # echo "✅ Deployment complete!"
# # echo "waiting for services to be ready..."
# # kubectl wait --for=condition=ready pod -l app=task-service -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=user-service -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=notification-service -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=analytics-service -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=api-gateway -n taskflow --timeout=120s
# # kubectl wait --for=condition=ready pod -l app=frontend -n taskflow --timeout=120s

# echo ""
# echo "📊 Status:"
# kubectl get pods -n luxe-backend
# echo ""
# kubectl get services -n luxe-backend
# echo ""
# kubectl get pods -n luxe-frontend
# echo ""
# echo ""
# kubectl get services -n luxe-frontend
# echo ""
# echo ""
# echo "🌐 Verify and Access the app:"
# echo "   kubectl get pods -n luxe-backend"
# echo "   kubectl get pods -n luxe-frontend"
# echo "   kubectl port-forward service/frontend 80:80 -n luxe-frontend"



# # =================================================================================================
























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