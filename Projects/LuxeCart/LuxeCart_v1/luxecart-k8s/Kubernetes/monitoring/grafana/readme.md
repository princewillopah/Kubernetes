 ### Install Grafana:
```
 helm install grafana grafana/grafana \
  --namespace luxe-observability \
  --values grafana-values.yaml \
  --wait \
  --timeout 10m
```

### Verify installation

```
kubectl get pods -n luxe-observability -l app.kubernetes.io/name=grafana
kubectl get svc -n luxe-observability grafana
```


















