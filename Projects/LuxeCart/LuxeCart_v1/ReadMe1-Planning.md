## 🔴 Architecture Strategy for KIND (Phase 1)
- Kind is single-node by default. Therefore:
- Databases → Single replica StatefulSets
- RabbitMQ → Single replica StatefulSet
- Elasticsearch → Single node (discovery.type=single-node)
- Redis → Standalone with AOF
- No HA yet
- StorageClass → default standard (kind local-path)
- We build it clean but non-HA.


## 🔴 Kubernetes Project Structure (Raw YAML – Production Organized)
You will structure LuxeCart like this:

```YAML
luxecart-k8s/
│
├── namespaces/
│   ├── edge.yaml
│   ├── application.yaml
│   ├── data.yaml
│   ├── messaging.yaml
│   ├── observability.yaml
│   └── frontend.yaml
│
├── data/
│   ├── postgres/
│   ├── redis/
│   ├── mongodb/
│   └── elasticsearch/
│
├── messaging/
│   └── rabbitmq/
│
├── application/
│   ├── api-gateway/
│   ├── auth-service/
│   ├── user-service/
│   └── ...
│
├── observability/
│   ├── prometheus/
│   ├── grafana/
│   ├── loki/
│   └── exporters/
│
└── frontend/
```

## 🔴 Dependency Model (Important)
Kubernetes does NOT use depends_on. <br>
We enforce startup correctness using:

1️⃣ Readiness Probes (Primary Gate) <br>
Service does not receive traffic until healthy.

2️⃣ InitContainers (Hard Dependency Gate) <br>
Example for auth-service: <br>
- wait for postgres <br>
- wait for rabbitmq <br>

Using nc, pg_isready, or curl.

3️⃣ Services (ClusterIP only) <br>
All internal communication is via DNS:
- postgres.data.svc.cluster.local
- rabbitmq.messaging.svc.cluster.local

## 🔴 Secrets Strategy <br>
We will create:
- postgres-secret
- rabbitmq-secret
- jwt-secret
- grafana-secret
- smtp-secret <br>

No plaintext passwords in Deployment YAML.


## 🔴 ConfigMaps Strategy
We will externalize:

- rabbitmq.conf
- enabled_plugins
- prometheus.yml
- loki-config.yaml
- promtail-config.yaml
- grafana provisioning

## 🔴 Storage Strategy (Kind)
Each stateful system:
```yaml
volumeClaimTemplates:
  storageClassName: standard
  resources:
    requests:
      storage: 5Gi
```
For kind, standard uses local-path provisioner.

## 🔴 Resource Requests & Limits (Baseline for kind)
Databases:
```yaml
requests:
  cpu: 200m
  memory: 512Mi
limits:
  cpu: 500m
  memory: 1Gi
```
<br>

Microservices:
```yaml
requests:
  cpu: 100m
  memory: 128Mi
limits:
  cpu: 300m
  memory: 256Mi
```
<br>

Prometheus:
```yaml
requests:
  cpu: 300m
  memory: 512Mi
limits:
  cpu: 800m
  memory: 1Gi
```
We will tune later for EKS.

## 🔴 Services Strategy

For Phase 1:
 - All services → ClusterIP
 - API Gateway → NodePort (temporary)
 - Frontend → NodePort (temporary)

<br>

We will use:
```yaml
kubectl port-forward svc/api-gateway 3000:3000 -n edge
```
No ingress yet.


## 🔴 Stateful Workloads (Mandatory)
These will be StatefulSets:
- postgres
- redis
- mongodb
- elasticsearch
- rabbitmq
- prometheus
- grafana
- loki
Everything else = Deployment.

## 🔴 What We Build First
We do this in layers to avoid chaos.

STEP 1 – Namespaces <br>
STEP 2 – Secrets <br>
STEP 3 – Data Tier (Postgres first) <br>
STEP 4 – Redis <br>
STEP 5 – RabbitMQ <br>
STEP 6 – Elasticsearch <br>
STEP 7 – MongoDB <br>
STEP 8 – API Gateway <br>
STEP 9 – One Microservice (auth) to validate pattern <br>
STEP 10 – Replicate pattern to remaining 14 services <br>
STEP 11 – Observability stack <br>
STEP 12 – Frontend <br>

We validate after each layer.


## 🔥 Important Production Note
Even for kind, we will:
- Use readiness & liveness probes
- Use securityContext (non-root where possible)
- Use resource constraints
- Use proper DNS service names
- Use InitContainers properly <br>

We are not doing a toy deployment.









