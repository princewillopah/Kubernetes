#!/bin/bash
set -e

# REGISTRY_NAME="princewillopah2"
# backend_image="$REGISTRY_NAME/taskflow-app_backend"
# frontend_image="$REGISTRY_NAME/taskflow-app_frontend"
# image_tag="v-1.1.6"
# current_dir=$(pwd)





# REGISTRY_NAME="princewillopah2" # Change this to your DockerHub username or registry URL if using a different registry
# APP_NAME="taskflow-micro-services"
# image_tag="1.0.0"
# current_dir=$(pwd)

# # Login to DockerHub
# echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

# echo ""
# echo " ================================================================= "
# echo "📦 Building and pushing images to $REGISTRY_NAME..."
# echo " ================================================================= "
# SERVICES="analytics-service recommendation-service email-service auth-service user-service product-service cart-service order-service review-service rating-service payment-service notification-service admin-service inventory-service search-service api-gateway-service frontend"

# for service in $SERVICES; do
# # Set build context for frontend
#   dir="./applications/services/$service"
#   if [ "$service" == "frontend" ]; then
#     dir="./applications/frontend"
#   fi


#   echo "Building $service..."
#   docker build -t $REGISTRY/$APP_NAME-$service:$image_tag $dir
#   docker push $REGISTRY/$APP_NAME-$service:$image_tag
#   echo ""
# done


# echo "✅ Services are completely built and pushed to DockerHub"
# echo ""
# echo "Copy the following to kubernetes yaml files"
# echo "------------------------------------------------------------------"
# for service in $SERVICES; do
#   echo "$REGISTRY/$APP_NAME-$service:$image_tag"
# done






















# curl -X POST \
#   https://hub.docker.com/v2/repositories/ \
#   -H 'Content-Type: application/json' \
#   -H "Authorization: Bearer $(echo $DOCKER_PASSWORD2 | docker login -u $DOCKER_USERNAME2 --password-stdin | grep -o 'token=.*')" \
#   -d '{"name": "taskflow-app/backend", "description": "My repo"}'


# # Login to DockerHub
# echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

# echo " ================================================================= "
# echo " Build backend image "
# echo " ================================================================= "
# docker build -t $backend_image:$image_tag $current_dir/backend

# echo " ================================================================= "
# echo " Push Backend image to Dockerhub "
# echo " ================================================================= "
# docker push $backend_image:$image_tag

# echo ""
# echo " ================================================================= "
# echo " Build frontend image "
# echo " ================================================================= "
# docker build -t $frontend_image:$image_tag $current_dir/frontend

# echo " ================================================================= "
# echo " Push Frontend image to Dockerhub "
# echo " ================================================================= "
# docker push $frontend_image:$image_tag

# echo ""
# echo "copy the following to kubernetes yaml files"
# echo "$frontend_image:$image_tag"
# echo "$backend_image:$image_tag"






























BASE_DIR=~/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart_v1/luxecart-k8s/k8s/backend-services

for SERVICE_DIR in "$BASE_DIR"/*; do
    if [ -d "$SERVICE_DIR" ]; then
        SERVICE_NAME=$(basename "$SERVICE_DIR")

        echo "Creating manifests for $SERVICE_NAME"
        cp deployment.yaml "$SERVICE_DIR/deployment.yaml"
        cp service.yaml "$SERVICE_DIR/service.yaml"
        # touch "$SERVICE_DIR/deployment.yaml"
        # touch "$SERVICE_DIR/service.yaml"
        # touch "$SERVICE_DIR/configmap.yaml"
        # touch "$SERVICE_DIR/secret.yaml"

    fi
done

echo "All Kubernetes manifest files created successfully."