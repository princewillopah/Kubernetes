#### ======================================================================================
#### prometheus for grafana
#### ======================================================================================

Port-Forward:
    kubectl port-forward -n luxe-observability --address 0.0.0.0 svc/prometheus-grafana 3000:80



👉 Grafana does NOT show “services” automatically
👉 It only shows query results

TO SEE query results
✅ Instead: use PromQL properly
Go to Grafana → Explore

Run:
    up{namespace="luxe-backend"}
Then group them:
    count by (service) (up{namespace="luxe-backend"})
If you want a “service view”
    sum by (service) (rate(http_requests_total[5m]))
