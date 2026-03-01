#!/bin/bash

# This script deploys the taskflow-ns Ecommerce application on a Kubernetes cluster
# using AWS Secret Manager for managing sensitive information.
# Check if namespace exists

namespace="taskflow-ns"

if kubectl get ns "$namespace" &> /dev/null; then
  echo "Deleting Old app in namespace $namespace..."
  kubectl delete ns "$namespace"
else
  echo "Namespace $namespace does not exist. Skipping deletion."
fi


echo "Namespace '$namespace' deleted."
# Apply the Kubernetes manifests
kubectl create namespace "$namespace"

# kubectl create secret generic aws-creds \
#   -n "$namespace" \
#   --from-literal=my-access-key=AKIAQHYZWNHQH7ZCCSMH\
#   --from-literal=my-secret-access-key=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

echo " "

current_dir=$(pwd)

# helm upgrade --install taskflow-ns ${current_dir} -n taskflow-ns
echo "------------------------------------------------------------------------" 
echo "Deploying Secrets: "
echo "------------------------------------------------------------------------"
helm upgrade --install taskflow-secrets ${current_dir}/charts/taskflow-secrets -n taskflow-ns #-f ${current_dir}/environments/prod/secrets.yaml
echo "------------------------------------------------------------------------ "
echo " "
echo "------------------------------------------------------------------------" 
echo "Deploying Backend: "
echo "------------------------------------------------------------------------"
helm upgrade --install taskflow-backend ${current_dir}/charts/taskflow-backend -n taskflow-ns #-f ${current_dir}/environments/prod/backend.yaml
echo " "
echo "------------------------------------------------------------------------ "
echo " "
echo "------------------------------------------------------------------------" 
echo "Deploying Frontend: "
echo "------------------------------------------------------------------------"
helm upgrade --install taskflow-frontend ${current_dir}/charts/taskflow-frontend -n taskflow-ns #-f ${current_dir}/environments/prod/frontend.yaml
echo "------------------------------------------------------------------------ "
echo " "



# echo " ================================================================= "
# echo "       Apply Network Policies to restrict traffic flow                "
# echo " ================================================================= "
# helm upgrade --install taskflow-network-policies ${current_dir}/charts/taskflow-network-policies  --namespace taskflow-ns
# echo "------------------------------------------------------------------------" 
# echo " "
# echo " ================================================================= "
# echo "       Others like service monitor for prometheus                "
# echo " ================================================================= "

#   kubectl delete servicemonitor mongodb -n  observability
#   kubectl delete servicemonitor frontend -n  observability
#   kubectl delete servicemonitor backend -n  observability

#   kubectl apply -f ${current_dir}/service-monitors/frontend-servicemonitor.yaml
#   kubectl apply -f ${current_dir}/service-monitors/backend-servicemonitor.yaml
#   kubectl apply -f ${current_dir}/service-monitors/mongo-servicemonitor.yaml

# echo "------------------------------------------------------------------------" 
echo " "
echo "Waiting for about 10 seconds for all pods to be in running state..."
echo " "
sleep 10
echo "------------------------------------------------------------------------" 
echo "All Helm Revisions status: "
echo "------------------------------------------------------------------------"
 
helm ls -n "$namespace"
echo "------------------------------------------------------------------------"
echo " "
echo "------------------------------------------------------------------------" 
echo "All deployed resources status: "
echo "------------------------------------------------------------------------"
 
kubectl get pods -n "$namespace"
echo "------------------------------------------------------------------------"
echo " "
# echo "------------------------------------------------------------------------" 
# echo "All Network Policies applied successfully. Current Network Policies: "
# echo "------------------------------------------------------------------------"
# kubectl get networkpolicy -n taskflow-ns
# echo "------------------------------------------------------------------------"




echo " "
echo "------------------------------------------------------------------------" 
echo "Other information: "
echo "------------------------------------------------------------------------"
echo " if any issue: kubectl get pods -n taskflow-ns"
# kubectl get pods -n taskflow-ns

echo " "
echo "kubectl port-forward -n taskflow-ns svc/frontend 8080:80"
# echo "kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n observability &"
# echo "kubectl port-forward svc/prometheus-grafana 3000:80 -n observability &"
# echo "kubectl port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093 -n observability &"
echo ""
echo "Then open your browser and navigate to: "
echo "Frontend: http://localhost:8080"
# echo "Prometheus: http://localhost:9090" 
# echo "Grafana: http://localhost:3000 (default credentials: admin/admin)"
# echo "Alertmanager: http://localhost:9093"
echo ""
# echo "------------------------------------------------------------------------"
# echo ""
# echo "--------------------------------------------------------------------------------------"
# echo " Test the network policies:"
# echo "--------------------------------------------------------------------------------------"
echo ""
echo "First, get the name of the pod:"
echo "kubectl get pods -n taskflow-ns"
# echo ""
# echo "Then, replace <frontend-pod> or <backend-pod>  with the actual pod name in the following commands below to test access to the service:"
# echo ""
# echo "Frontend → Mongo (MUST PASS): kubectl exec  <frontend-pod> -n taskflow-ns -- curl backend:5000/health"
# echo ""
# echo "Backend → Mongo (MUST PASS): kubectl exec  <backend-pod> -n taskflow-ns -- nc -zv mongo 27017"
# echo ""
# echo "Frontend → Mongo (MUST FAIL): kubectl exec -n taskflow-ns <frontend-pod> -- nc -zv mongo 27017"

# echo "taskflow-ns Ecommerce application deployed successfully!"
# echo "You can access the frontend service using port forwarding:"
# echo "Run the following command in a separate terminal:"
# echo ""
# echo "kubectl port-forward -n taskflow-ns svc/frontend 8080:80"
# echo ""
# echo "Then open your browser and navigate to: http://localhost:8080" 
# echo ""
# echo "Test if Network Policies are working as expected by trying to access backend service directly:"
# echo "Run the following command in a separate terminal:"
# echo ""
# echo "--------------------------------------------------------------------------------------"
# echo " Testing the network policys by attempting to access the backend service directly from a test pod:"
# echo "--------------------------------------------------------------------------------------"
# echo ""
# echo "First, get the name of the pod:"
# echo "kubectl get pods -n taskflow-ns"
# echo ""
# echo "Then, replace <frontend-pod> or <backend-pod>  with the actual pod name in the following commands below to test access to the service:"
# echo ""
# echo "Frontend → Mongo (MUST PASS): kubectl exec  <frontend-pod> -n taskflow-ns -- curl backend:5000/health"
# echo ""
# echo "Backend → Mongo (MUST PASS): kubectl exec  <backend-pod> -n taskflow-ns -- nc -zv mongo 27017"
# echo ""
# echo "Frontend → Mongo (MUST FAIL): kubectl exec -n taskflow-ns <frontend-pod> -- nc -zv mongo 27017"

# echo "--------------------------------------------------------------------------------------"
# echo ""
# echo "kubectl run -n taskflow-ns test-backend --rm -it --image=busybox -- /bin/sh"
# echo ""
# echo "Inside the test-backend pod, run:"
# echo "wget -qO- http://backend:5000/api/products"
# echo ""
# echo "You should see a timeout or connection refused message, indicating that the Network Policies are effectively restricting access."
# echo " "

# # -----------------------------------------------------------------------------
# # Note: 
# # -----------------------------------------------------------------------------
# # 1. Ensure that port 8080 on your local machine is free before running the port-forward command.
# # 2. If port 8080 is already in use, you can choose another available port, e.g., 8081, by modifying the command to:  
# #    kubectl port-forward -n taskflow-ns svc/frontend 8081:80
# # 3. After changing the port, access the application at http://localhost:8081
# # -----------------------------------------------------------------------------
# # 	Test Network Policies:
# # -----------------------------------------------------------------------------
# # 1. From within the frontend pod, try to access the backend service (should succeed
# #    Frontend → Backend
# # 	kubectl exec  <frontend-pod> -n taskflow-ns -- curl backend:5000/health
	
# # 	Backend → Mongo
# # 		kubectl exec <backend-pod> -n taskflow-ns  -- nc -zv mongo 27017
	
# # 	Frontend → Mongo (MUST FAIL)
# # kubectl exec -n taskflow-ns <frontend-pod> -- nc -zv mongo 27017
# # -----------------------------------------------------------------------------

# # how to confirm with various ways if a particular port is being used
# # netstat -tuln | grep 8080
# # lsof -i :8080
# # ss -tuln | grep 8080


