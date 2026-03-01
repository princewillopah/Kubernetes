#!/usr/bin/env bash
set -euo pipefail

namespace="demo-service-account"

if kubectl get ns "$namespace" &> /dev/null; then
  echo "Deleting Old app in namespace $namespace..."
  kubectl delete ns "$namespace"
  echo "Namespace '$namespace' deleted."
else
  echo "Namespace $namespace does not exist. Skipping deletion."
fi



# Apply the Kubernetes manifests
kubectl create namespace "$namespace"

echo " "
kubectl apply -f objects.yaml -n "$namespace"
echo " "
kubectl get sa -n "$namespace"
echo " "
kubectl get roles -n "$namespace"
echo " "
kubectl get rolebinding -n "$namespace"
echo " "
kubectl get pods -n "$namespace"




# kubectl describe pod busybox -n "$namespace"
# kubectl logs busybox -n "$namespace"
# kubectl exec -it busybox -n "$namespace" -- sh
# kubectl delete namespace "$namespace"