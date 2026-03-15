kubectl apply -f backend-servicemonitor.yaml
kubectl apply -f infra-servicemonitor.yaml
kubectl apply -f frontend-servicemonitor.yaml

kubectl get servicemonitor -n luxe-observability
# Expected: luxecart-backend, luxecart-infra, luxecart-frontend



helm install prometheus prometheus-community/kube-prometheus-stack -n luxe-observability --create-namespace
kubectl get crd | grep monitor
kubectl get pods -n luxe-observability