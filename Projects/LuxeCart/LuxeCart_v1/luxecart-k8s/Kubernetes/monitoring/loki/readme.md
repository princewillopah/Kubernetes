Run:
    helm upgrade loki grafana/loki --namespace luxe-observability -f loki-values.yaml

confirm:
    kubectl get po -n luxe-observability
    kubectl get svc -n luxe-observability

Run:
    kubectl port-forward svc/loki 3100:3100 -n luxe-observability
Verify
    curl http://localhost:3100/ready
Expectation: 
    ready
Test:
    curl http://localhost:3100/loki/api/v1/status/buildinfo
Expectation:
    {"version":"3.6.7","revision":"7e1daf3a","branch":"release-3.6.x","buildUser":"root@buildkitsandbox","buildDate":"2026-02-23T09:20:31Z","goVersion":""}