
###  Install Ingress Controller via Helm

`# Create namespace`
```yaml
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -
# Install in its own namespace 'ingress-nginx' (industry standard)
```
<br>

`# Install Helm release `

```yaml
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --values ingress-nginx-values.yaml \
  --wait \
  --timeout 10m
```

<br>

`# Verify installation`
```yaml
kubectl get pods -n ingress-nginx
# Expected: ingress-nginx-controller-* showing 1/1 Running
```
```yaml
kubectl get svc -n ingress-nginx
# Expected: ingress-nginx-controller with NodePort 30080:30443
```