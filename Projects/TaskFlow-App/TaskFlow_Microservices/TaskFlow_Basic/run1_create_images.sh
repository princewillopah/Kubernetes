#!/bin/bash
set -e

echo "☸️  Deploying TaskFlow to Kubernetes"
echo ""

REGISTRY="princewillopah2" # Change this to your DockerHub username or registry URL if using a different registry
APP_NAME="taskflow-micro-services"
image_tag="1.0.0"


# Login to DockerHub
echo "$DOCKER_PASSWORD2" | docker login -u "$DOCKER_USERNAME2" --password-stdin

echo ""
echo " ================================================================= "
echo "📦 Building and pushing images to $REGISTRY..."
echo " ================================================================= "

services="task-service user-service notification-service analytics-service api-gateway frontend"
for service in $services; do
# Set build context for frontend
  dir="./Apps/services/$service"
  if [ "$service" == "frontend" ]; then
    dir="./Apps/frontend"
  fi


  echo "Building $service..."
  docker build -t $REGISTRY/$APP_NAME-$service:$image_tag $dir
  docker push $REGISTRY/$APP_NAME-$service:$image_tag
  echo ""
done


echo "✅ Services are completely built and pushed to DockerHub"
echo ""
echo "Copy the following to kubernetes yaml files"
echo "------------------------------------------------------------------"
for service in $services; do
  echo "$REGISTRY/$APP_NAME-$service:$image_tag"
done

# Result:
# princewillopah2/taskflow-micro-services-task-service:1.0.0
# princewillopah2/taskflow-micro-services-user-service:1.0.0
# princewillopah2/taskflow-micro-services-notification-service:1.0.0
# princewillopah2/taskflow-micro-services-analytics-service:1.0.0
# princewillopah2/taskflow-micro-services-api-gateway:1.0.0
# princewillopah2/taskflow-micro-services-frontend:1.0.0