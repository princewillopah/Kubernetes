## ✅ STEP 1 — Namespaces (Separate Files)
<h3 style="color: #947cb9; font-weight: bold; padding-bottom: -200px">Directory: </h3>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; `luxecart-k8s/namespaces/`

<br>



<h3 style="color: #947cb9; font-weight: bold;">01 — edge.yaml</h3>

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: edge
  labels:
    name: edge
    app.kubernetes.io/part-of: luxecart
```
 <br>

<h3 style="color: #947cb9; font-weight: bold;">02 — application.yaml</h3>

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: application
  labels:
    name: application
    app.kubernetes.io/part-of: luxecart
```
 <br>

<h3 style="color: #947cb9; font-weight: bold;">03 — data.yaml</h3>

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: data
  labels:
    name: data
    app.kubernetes.io/part-of: luxecart
```
 <br>

<h3 style="color: #947cb9; font-weight: bold;">04 — messaging.yaml</h3>

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: messaging
  labels:
    name: messaging
    app.kubernetes.io/part-of: luxecart
```
 <br>

<h3 style="color: #947cb9; font-weight: bold;">05 — observability.yaml</h3>

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: observability
  labels:
    name: observability
    app.kubernetes.io/part-of: luxecart
```
 <br>

<h3 style="color: #947cb9; font-weight: bold;">06 — frontend.yaml</h3>

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: frontend
  labels:
    name: frontend
    app.kubernetes.io/part-of: luxecart
```

<h3 style="color: #947cb9; font-weight: bold;">Deploy Namespaces</h3>

 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`kubectl apply -f namespaces/`
<br><br>

<h3 style="color: #947cb9; font-weight: bold;">Verify</h3>

  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;`kubectl get ns`

You should see:
```yaml
edge
application
data
messaging
observability
frontend
```



## ✅ STEP 2 — PostgreSQL (Production Baseline for KIND)
<h3 style="color: #947cb9; font-weight: bold; padding-bottom: -200px">Directory: </h3>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; `luxecart-k8s/data/postgres/` 

We create:
  - Secret
  - Headless Service
  - ClusterIP Service
  - StatefulSet


<h3 style="color: #947cb9; font-weight: bold;">01 — postgres-secret.yaml</h3>

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: data
type: Opaque
stringData:
  POSTGRES_DB: luxecart
  POSTGRES_USER: luxecart_user
  POSTGRES_PASSWORD: strongpassword123
```
⚠️ For production:
- Never commit plaintext.
- Use SealedSecrets or ExternalSecrets.
- This is acceptable only for kind.

<h3 style="color: #947cb9; font-weight: bold;">02 — postgres-headless-service.yaml</h3>
Required for StatefulSet stable identity.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
  namespace: data
spec:
  clusterIP: None
  selector:
    app: postgres
  ports:
    - port: 5432
      name: postgres
```

<h3 style="color: #947cb9; font-weight: bold;">03 — postgres-service.yaml</h3>
Internal ClusterIP for services.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres
  namespace: data
spec:
  type: ClusterIP
  selector:
    app: postgres
  ports:
    - port: 5432
      targetPort: 5432
```
DNS will be:
```yaml
postgres.data.svc.cluster.local
```

<h3 style="color: #947cb9; font-weight: bold;">04 — postgres-statefulset.yaml</h3>

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: data
spec:
  serviceName: postgres-headless
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      securityContext:
        fsGroup: 999
      containers:
        - name: postgres
          image: postgres:15-alpine
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 5432
              name: postgres
          envFrom:
            - secretRef:
                name: postgres-secret
          resources:
            requests:
              cpu: 200m
              memory: 512Mi
            limits:
              cpu: 500m
              memory: 1Gi
          readinessProbe:
            exec:
              command:
                - sh
                - -c
                - pg_isready -U "$POSTGRES_USER"
            initialDelaySeconds: 10
            periodSeconds: 5
            failureThreshold: 5
          livenessProbe:
            exec:
              command:
                - sh
                - -c
                - pg_isready -U "$POSTGRES_USER"
            initialDelaySeconds: 30
            periodSeconds: 10
            failureThreshold: 5
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
    - metadata:
        name: postgres-data
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: standard
        resources:
          requests:
            storage: 5Gi
```

<h3 style="color: #947cb9; font-weight: bold;">Deploy PostgreSQL</h3>

```yaml
kubectl apply -f data/postgres/
```

<h3 style="color: #947cb9; font-weight: bold;">Verify:</h3>

```yaml
kubectl get pods -n data
kubectl get pvc -n data
kubectl get svc -n data
```
Expected:
- postgres-0 Running
- PVC bound
- 2 services created

<h3 style="color: #947cb9; font-weight: bold;">Validation Test:</h3>
Run:

```yaml
kubectl run pg-test --rm -it --image=postgres:15-alpine -n data -- sh
```
from inside the pod, Run
```YAML
psql -h postgres -U luxecart_user -d luxecart
```
If it connects → Database is correctly deployed.