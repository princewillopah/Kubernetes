##### Directory Structure


```
taskflow-backend/
├── Chart.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service-main.yaml
│   ├── service-blue.yaml
│   ├── service-green.yaml
│   └── configmap.yaml (if you have)
├── values.yaml (default)
├── values-blue.yaml
├── values-green.yaml
└── switch-blue-green.sh

```






### Key Benefits of This Setup:
1. Zero-downtime deployments

2. Easy rollback by switching back to previous color

3. Parallel testing in production-like environment

4. Gradual traffic migration possible with Ingress