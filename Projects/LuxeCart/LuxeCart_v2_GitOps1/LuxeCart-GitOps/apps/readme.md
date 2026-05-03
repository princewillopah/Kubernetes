# create Sealed secrets


### Below are Kubernetes Secrets for Luxecart
```yaml

apiVersion: v1
kind: Secret
metadata:
  name: mongodb-secret
  namespace: luxe-infra
type: Opaque
stringData:
  MONGO_INITDB_ROOT_USERNAME: luxeadmin
  MONGO_INITDB_ROOT_PASSWORD: luxeadmin-strong-root-password



apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq-secret
  namespace: luxe-infra
type: Opaque
stringData:
  RABBITMQ_DEFAULT_USER: ecommerce
  RABBITMQ_DEFAULT_PASS: strong-rabbit-password


apiVersion: v1
kind: Secret
metadata:
  name: redis-secret
  namespace: luxe-infra
type: Opaque
stringData:
  REDIS_PASSWORD: luxe-cart-redis-password



apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: luxe-infra
type: Opaque
stringData:
  POSTGRES_USER: ecommerce
  POSTGRES_PASSWORD: ecommerce123
  POSTGRES_DB: ecommerce


apiVersion: v1
kind: Secret
metadata:
  name: flaway-auth-secret
  namespace: luxe-infra
type: Opaque
stringData:
  FLYWAY_USER: ecommerce
  FLYWAY_PASSWORD: ecommerce123
  FLYWAY_URL: jdbc:postgresql://postgres.luxe-infra.svc.cluster.local:5432/ecommerce
  POSTGRES_DB_URL: postgresql://ecommerce:ecommerce123@postgres.luxe-infra.svc.cluster.local:5432/ecommerce?sslmode=disable


apiVersion: v1
kind: Secret
metadata:
  name: jwt-auth-secret
  namespace: luxe-backend
type: Opaque
stringData:
  JWT_SECRET: your-secret-key-change-in-production
 

apiVersion: v1
kind: Secret
metadata:
  name: postgres-connection
  namespace: luxe-backend
type: Opaque
stringData:
  DATABASE_URL: postgresql://ecommerce:ecommerce123@postgres.luxe-infra.svc.cluster.local:5432/ecommerce


apiVersion: v1
kind: Secret
metadata:
  name: redis-connection
  namespace: luxe-backend
type: Opaque
stringData:
  REDIS_URL: redis://:luxe-cart-redis-password@redis.luxe-infra.svc.cluster.local:6379


apiVersion: v1
kind: Secret
metadata:
  name: rabbitmq-connection
  namespace: luxe-backend
type: Opaque
stringData:
  RABBITMQ_URL: amqp://ecommerce:strong-rabbit-password@rabbitmq.luxe-infra.svc.cluster.local:5672


apiVersion: v1
kind: Secret
metadata:
  name: mongodb-connection
  namespace: luxe-backend
type: Opaque
stringData:
  MONGODB_URL: mongodb://luxeadmin:luxeadmin-strong-root-password@mongodb.luxe-infra.svc.cluster.local:27017/maildb?authSource=admin


apiVersion: v1
kind: Secret
metadata:
  name: elasticsearch-connection
  namespace: luxe-backend
type: Opaque
stringData:
  ELASTICSEARCH_URL: http://elasticsearch.luxe-infra.svc.cluster.local:9200


apiVersion: v1
kind: Secret
metadata:
  name: email-secrets
  namespace: luxe-backend
type: Opaque
stringData:
  SMTP_USER: noreply@luxecart.com
  FROM_EMAIL: LuxeCart <noreply@luxecart.com>
  SMTP_PASSWORD: my-smtp-password-in-production



apiVersion: v1
kind: Secret
metadata:
  name: grafana-secret
  namespace: luxe-observability
type: Opaque
stringData:
  GRAFANA_USER: admin
  GRAFANA_PASSWORD: admin


```

#### we can use the secrets files to generate sealed secrets or just create the k8s secrets using the literals below



```yaml
Structure:
apps
├── backend
│   ├── app.yaml
│   └── secrets
│         ├── jwt-auth-sealed-secret.yaml
│         ├── postgres-connection-sealed-secret.yaml
│         ├── redis-connection-sealed-secret.yaml
│         ├── rabbitmq-connection-sealed-secret.yaml
│         ├── mongodb-connection-sealed-secret.yaml
│         ├── elasticsearch-connection-sealed-secret.yaml
│         └── email-secrets-sealed-secret.yaml
├── frontend
│   └── app.yaml
├── infra
│   ├── app.yaml
│   └── secrets
│         ├── mongodb-sealed-secret.yaml
│         ├── redis-sealed-secret.yaml
│         ├── rabbitmq-sealed-secret.yaml
│         ├── flaway-auth-sealed-secret.yaml
│         └── postgres-sealed-secret.yaml
└── readme.md

---------------------------------------------------------------------------------
# luxe-infra Sealed secrets
---------------------------------------------------------------------------------
# mongodb-sealed-secret.yaml:
kubectl create secret generic mongodb-secret \
  --from-literal=MONGO_INITDB_ROOT_USERNAME=luxeadmin \
  --from-literal=MONGO_INITDB_ROOT_PASSWORD=luxeadmin-strong-root-password \
  --dry-run=client -o yaml > mongodb-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-infra \
  -f mongodb-k8s-secret.yaml \
  -o yaml > mongodb-sealed-secret.yaml

-------------------------------------------------------------------------
# rabbitmq-sealed-secret.yaml
kubectl create secret generic rabbitmq-secret \
  --from-literal=RABBITMQ_DEFAULT_USER=ecommerce \
  --from-literal=RABBITMQ_DEFAULT_PASS=strong-rabbit-password \
  --dry-run=client -o yaml > rabbitmq-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-infra \
  -f rabbitmq-k8s-secret.yaml \
  -o yaml > rabbitmq-sealed-secret.yaml

-------------------------------------------------------------------------
#redis-sealed-secret.yaml
kubectl create secret generic redis-secret \
  --from-literal=REDIS_PASSWORD=luxe-cart-redis-password \
  --dry-run=client -o yaml > redis-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-infra \
  -f redis-k8s-secret.yaml \
  -o yaml > redis-sealed-secret.yaml

-------------------------------------------------------------------------
#postgres-k8s-secret.yaml
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_DB=ecommerce \
  --from-literal=POSTGRES_USER=ecommerce \
  --from-literal=POSTGRES_PASSWORD=ecommerce123 \
  --dry-run=client -o yaml > postgres-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-infra \
  -f postgres-k8s-secret.yaml \
  -o yaml > postgres-sealed-secret.yaml

-------------------------------------------------------------------------
#flaway-auth-sealed-secret.yaml
kubectl create secret generic flaway-auth-secret \
  --from-literal=FLYWAY_USER=ecommerce \
  --from-literal=FLYWAY_PASSWORD=ecommerce123 \
  --from-literal=FLYWAY_URL=jdbc:postgresql://postgres.luxe-infra.svc.cluster.local:5432/ecommerce \
  --from-literal=POSTGRES_DB_URL=postgresql://ecommerce:ecommerce123@postgres.luxe-infra.svc.cluster.local:5432/ecommerce?sslmode=disable \
  --dry-run=client -o yaml > flaway-auth-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-infra \
  -f flaway-auth-k8s-secret.yaml \
  -o yaml > flaway-auth-sealed-secret.yaml

---------------------------------------------------------------------------------
# luxe-backend Sealed secrets
---------------------------------------------------------------------------------

#jwt-auth-sealed-secret.yaml
kubectl create secret generic jwt-auth-secret \
  --from-literal=JWT_SECRET=your-secret-key-change-in-production \
  --dry-run=client -o yaml > jwt-auth-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-backend \
  -f jwt-auth-k8s-secret.yaml \
  -o yaml > jwt-auth-sealed-secret.yaml

--------------------------------------------------------------------------
#postgres-connection-sealed-secret.yaml
kubectl create secret generic postgres-connection \
  --from-literal=DATABASE_URL=postgresql://ecommerce:ecommerce123@postgres.luxe-infra.svc.cluster.local:5432/ecommerce \
  --dry-run=client -o yaml > postgres-connection-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-backend \
  -f postgres-connection-k8s-secret.yaml \
  -o yaml > postgres-connection-sealed-secret.yaml


--------------------------------------------------------------------------
#redis-connection-sealed-secret.yaml
kubectl create secret generic redis-connection \
  --from-literal=REDIS_URL=redis://:luxe-cart-redis-password@redis.luxe-infra.svc.cluster.local:6379 \
  --dry-run=client -o yaml > redis-connection-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-backend \
  -f redis-connection-k8s-secret.yaml \
  -o yaml > redis-connection-sealed-secret.yaml

---------------------------------------------------------------------------

# rabbitmq-connection-k8s-secret.yaml
kubectl create secret generic rabbitmq-connection \
  --from-literal=RABBITMQ_URL=amqp://ecommerce:strong-rabbit-password@rabbitmq.luxe-infra.svc.cluster.local:5672 \
  --dry-run=client -o yaml > rabbitmq-connection-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-backend \
  -f rabbitmq-connection-k8s-secret.yaml \
  -o yaml > rabbitmq-connection-sealed-secret.yaml

--------------------------------------------------------------------------
#mongodb-connection-sealed-secret.yaml
kubectl create secret generic mongodb-connection \
  --from-literal=MONGODB_URL=mongodb://luxeadmin:luxeadmin-strong-root-password@mongodb.luxe-infra.svc.cluster.local:27017/maildb?authSource=admin \
  --dry-run=client -o yaml > mongodb-connection-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-backend \
  -f mongodb-connection-k8s-secret.yaml \
  -o yaml > mongodb-connection-sealed-secret.yaml

-------------------------------------------------------------------------
#elasticsearch-connection-sealed-secret.yaml
kubectl create secret generic elasticsearch-connection \
  --from-literal=ELASTICSEARCH_URL=http://elasticsearch.luxe-infra.svc.cluster.local:9200 \
  --dry-run=client -o yaml > elasticsearch-connection-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-backend \
  -f elasticsearch-connection-k8s-secret.yaml \
  -o yaml > elasticsearch-connection-sealed-secret.yaml

-------------------------------------------------------------------------
#email-secrets-sealed-secret.yaml
kubectl create secret generic email-secrets \
  --from-literal=SMTP_USER=noreply@luxecart.com \
  --from-literal=FROM_EMAIL="LuxeCart <noreply@luxecart.com>" \
  --from-literal=SMTP_PASSWORD=my-smtp-password-in-production \
  --dry-run=client -o yaml > email-secrets-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-backend \
  -f email-secrets-k8s-secret.yaml \
  -o yaml > email-secrets-sealed-secret.yaml

---------------------------------------------------------------------------------
# luxe-observability Sealed secrets
---------------------------------------------------------------------------------
#grafana-secrets-sealed-secret.yaml
kubectl create secret generic grafana-secrets \
  --from-literal=SMTP_USER=noreply@luxecart.com \
  --from-literal=FROM_EMAIL=LuxeCart <noreply@luxecart.com> \
  --from-literal=SMTP_PASSWORD=my-smtp-password-in-production \
  --dry-run=client -o yaml > grafana-secrets-k8s-secret.yaml

kubeseal \
  --cert /home/princewillopah/DevOps/Kubernetes/Projects/LuxeCart/LuxeCart-GitOps/sealed-secrets-cert.pem \
  --namespace luxe-observability \
  -f grafana-secrets-k8s-secret.yaml \
  -o yaml > grafana-secrets-sealed-secret.yaml


Created are:
- mongodb-sealed-secret.yaml
- redis-sealed-secret.yaml
- rabbitmq-sealed-secret.yaml
- flaway-auth-sealed-secret.yaml
- postgres-sealed-secret.yaml
- jwt-auth-sealed-secret.yaml
- postgres-connection-sealed-secret.yaml
- redis-connection-sealed-secret.yaml
- rabbitmq-connection-sealed-secret.yaml
- mongodb-connection-sealed-secret.yaml
- elasticsearch-connection-sealed-secret.yaml
- email-secrets-sealed-secret.yaml
- grafana-secrets-sealed-secret.yaml


Remove/Delete:
rm mongodb-k8s-secret.yaml rabbitmq-k8s-secret.yaml redis-k8s-secret.yaml flaway-auth-k8s-secret.yaml postgres-k8s-secret.yaml

rm jwt-auth-k8s-secret.yaml postgres-connection-k8s-secret.yaml

rm mongodb-connection-k8s-secret.yaml elasticsearch-connection-k8s-secret.yaml email-secrets-k8s-secret.yaml rabbitmq-connection-k8s-secret.yaml redis-connection-k8s-secret.yaml

rm grafana-secrets-k8s-secret.yaml






```
