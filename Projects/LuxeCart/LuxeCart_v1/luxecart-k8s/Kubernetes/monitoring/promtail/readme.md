Run:
    helm install promtail grafana/promtail --namespace luxe-observability -f promtail-values.yaml

Verify Promtail
    kubectl get pods -n luxe-observability

Confirm Logs Are Being Sent
    kubectl logs -n luxe-observability -l app.kubernetes.io/name=promtail










Test Loki From Grafana
Open Grafana → Explore → Loki.

Run query:
{namespace="luxe-backend"}

Or all LuxeCart logs:

{cluster="kind-luxecart"}

---------------------------------------------------

Correct Test Pod inside a monitored namespace:
    kubectl run log-test \
        -n luxe-backend \
        --image=busybox \
        --restart=Never \
        -- sh -c 'while true; do echo "luxecart-log-test $(date)"; sleep 2; done'


Confirm Promtail Detects It:
    kubectl logs -n luxe-observability -l app.kubernetes.io/name=promtail | grep log-test
You should now see something like:
    Adding target /var/log/pods/luxe-backend_log-test...

---------------------------------------
Query Loki Again
---------------------------------------
Port-forward Loki if not running:
    kubectl port-forward -n luxe-observability svc/loki 3100:3100

Then query:
    curl -G http://localhost:3100/loki/api/v1/query_range \
        --data-urlencode 'query={pod="log-test"}' \
        --data-urlencode 'limit=20'


If Everything Works (Expected LuxeCart Flow)
Your logging pipeline is now confirmed:

LuxeCart Pods
      │
stdout logs
      │
/var/log/pods
      │
Promtail (DaemonSet)
      │
      ▼
Loki
      │
      ▼
Grafana





















