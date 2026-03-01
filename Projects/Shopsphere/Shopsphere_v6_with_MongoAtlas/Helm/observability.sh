namespace="observability"

if kubectl get ns "$namespace" &> /dev/null; then
  echo "Deleting Old app in namespace $namespace..."
  kubectl delete ns "$namespace"
else
  echo "Namespace $namespace does not exist. Skipping deletion."
fi

echo "Namespace '$namespace' deleted."

echo "Creating New Namespace '$namespace'..."
kubectl create namespace "$namespace"

echo "Installing Prometheus and Grafana in namespace '$namespace'..."
# Add the Prometheus Community Helm repository
helm install prometheus prometheus-community/kube-prometheus-stack \
	  --namespace "$namespace" \
	  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
	  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
	  --set prometheus.prometheusSpec.retention=30d \
	  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]=ReadWriteOnce \
	  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=20Gi \
	  --set grafana.persistence.enabled=true \
	  --set grafana.persistence.size=10Gi


echo ""
# Access Prometheus (background process)
echo "kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n "$namespace" &"
# Access Grafana (background process)  
echo "kubectl port-forward svc/prometheus-grafana 3000:80 -n "$namespace" &"
# Access AlertManager (background process)
echo "kubectl port-forward svc/prometheus-kube-prometheus-alertmanager 9093:9093 -n "$namespace" &"

echo ""
echo "Now you can access:"
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000"
echo "AlertManager: http://localhost:9093"

echo ""
echo "Get password:"
echo "kubectl get secret -n "$namespace" prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d"
echo "kubectl get secret prometheus-grafana -n "$namespace" -o go-template='{{ index .data "admin-user" | base64decode }}:{{ index .data "admin-password" | base64decode }}'"


echo "Waiting for about 15 seconds for Prometheus and Grafana to initialize..."
echo ""
sleep 15
echo "------------------------------------------------------------------------" 
echo "Pods in namespace '$namespace':"
echo "------------------------------------------------------------------------"
kubectl get pods -n "$namespace"

