# 🚀 Kubernetes Deployment Guide - LuxeCart E-Commerce

Complete guide to deploying the microservices e-commerce platform on Kubernetes.

---

## 📋 **Prerequisites**

### 1. **Kubernetes Cluster**
- Kubernetes 1.24+ (supports autoscaling/v2)
- kubectl configured to access your cluster
- At least 3 nodes with 4GB RAM each

**Cluster Options:**
- **Local:** Minikube, Kind, k3s, Docker Desktop
- **Cloud:** EKS (AWS), GKE (Google), AKS (Azure), DigitalOcean Kubernetes
- **Self-hosted:** kubeadm, k3s, RKE

### 2. **Container Registry**
You need to build and push Docker images to a registry:
- Docker Hub (public/private)
- AWS ECR
- Google Container Registry (GCR)
- Azure Container Registry (ACR)
- GitHub Container Registry (ghcr.io)
- Private registry

### 3. **Ingress Controller** (Optional but recommended)
```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# OR Traefik
helm repo add traefik https://traefik.github.io/charts
helm install traefik traefik/traefik --namespace traefik --create-namespace
```

### 4. **Metrics Server** (for HPA autoscaling)
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

## 🏗️ **SEEDING STRATEGY IN KUBERNETES**

### **How Database Seeding Works:**

```
┌─────────────────────────────────────────────────┐
│  Step 1: PostgreSQL Pod Starts                 │
│  ├─ Mounts ConfigMap (schema.sql)              │
│  ├─ Runs schema.sql on first boot              │
│  ├─ Creates tables                             │
│  └─ Inserts seed data with placeholder pwd     │
│     • admin@ecommerce.com (NEEDS_BCRYPT_HASH)  │
│     • 4 test users (NEEDS_BCRYPT_HASH)         │
│     • 6 products                                │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│  Step 2: Auth Service Starts                   │
│  ├─ Connects to PostgreSQL                     │
│  ├─ Runs fixSeedPasswords() function           │
│  ├─ Generates bcrypt hash for "123456"         │
│  └─ Updates all placeholder passwords          │
│     UPDATE users SET password = '$2b$10$...'    │
│     WHERE password = 'NEEDS_BCRYPT_HASH'        │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│  Step 3: Ready to Use                          │
│  ✅ Database has tables + seed data            │
│  ✅ Users can login with password: 123456      │
│  ✅ Products are available                     │
└─────────────────────────────────────────────────┘
```

**Key Points:**
1. **ConfigMap** stores schema.sql
2. **PostgreSQL** runs it automatically on first boot
3. **Auth Service** fixes passwords after DB is ready
4. **No manual seeding** required!

**Data Persistence:**
- PostgreSQL uses **PersistentVolumeClaim** (10GB)
- Data survives pod restarts
- Seeding only runs on FIRST database initialization
- Delete PVC to re-seed (fresh start)

---

## 🔨 **STEP 1: Build Docker Images**

### **Option A: Build All Images Locally**

```bash
cd ecommerce-microservices

# Set your registry (CHANGE THIS!)
export REGISTRY="your-dockerhub-username"  # or ghcr.io/your-username

# Build all service images
docker build -t $REGISTRY/ecommerce-auth-service:latest ./services/auth-service
docker build -t $REGISTRY/ecommerce-user-service:latest ./services/user-service
docker build -t $REGISTRY/ecommerce-product-service:latest ./services/product-service
docker build -t $REGISTRY/ecommerce-cart-service:latest ./services/cart-service
docker build -t $REGISTRY/ecommerce-order-service:latest ./services/order-service
docker build -t $REGISTRY/ecommerce-review-service:latest ./services/review-service
docker build -t $REGISTRY/ecommerce-rating-service:latest ./services/rating-service
docker build -t $REGISTRY/ecommerce-payment-service:latest ./services/payment-service
docker build -t $REGISTRY/ecommerce-notification-service:latest ./services/notification-service
docker build -t $REGISTRY/ecommerce-admin-service:latest ./services/admin-service
docker build -t $REGISTRY/ecommerce-api-gateway:latest ./services/api-gateway
docker build -t $REGISTRY/ecommerce-frontend:latest ./frontend

# Push all images
docker push $REGISTRY/ecommerce-auth-service:latest
docker push $REGISTRY/ecommerce-user-service:latest
docker push $REGISTRY/ecommerce-product-service:latest
docker push $REGISTRY/ecommerce-cart-service:latest
docker push $REGISTRY/ecommerce-order-service:latest
docker push $REGISTRY/ecommerce-review-service:latest
docker push $REGISTRY/ecommerce-rating-service:latest
docker push $REGISTRY/ecommerce-payment-service:latest
docker push $REGISTRY/ecommerce-notification-service:latest
docker push $REGISTRY/ecommerce-admin-service:latest
docker push $REGISTRY/ecommerce-api-gateway:latest
docker push $REGISTRY/ecommerce-frontend:latest
```

### **Option B: Use Build Script**

Create `build-push.sh`:
```bash
#!/bin/bash
export REGISTRY="your-dockerhub-username"

services=(
  "auth-service"
  "user-service"
  "product-service"
  "cart-service"
  "order-service"
  "review-service"
  "rating-service"
  "payment-service"
  "notification-service"
  "admin-service"
  "api-gateway"
)

for service in "${services[@]}"; do
  echo "Building $service..."
  docker build -t $REGISTRY/ecommerce-$service:latest ./services/$service
  docker push $REGISTRY/ecommerce-$service:latest
done

# Frontend
docker build -t $REGISTRY/ecommerce-frontend:latest ./frontend
docker push $REGISTRY/ecommerce-frontend:latest
```

---

## 📝 **STEP 2: Update Image References**

Update ALL manifests in `k8s/` folder to use your registry:

```bash
# Find and replace (use your actual registry)
find k8s/ -name "*.yaml" -exec sed -i 's|your-registry|your-dockerhub-username|g' {} +
```

OR manually edit each deployment file and change:
```yaml
image: your-registry/ecommerce-auth-service:latest
```
to:
```yaml
image: yourusername/ecommerce-auth-service:latest
```

---

## 🚀 **STEP 3: Deploy to Kubernetes**

### **Deploy in Order (Dependencies Matter!)**

```bash
cd ecommerce-microservices/k8s

# 1. Create namespace
kubectl apply -f 00-namespace.yaml

# 2. Create ConfigMap (database schema)
kubectl apply -f 01-configmap-db-init.yaml

# 3. Create Secrets (IMPORTANT: Change passwords in production!)
kubectl apply -f 02-secrets.yaml

# 4. Deploy PostgreSQL (wait for it to be ready)
kubectl apply -f 03-postgres.yaml

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=300s

# 5. Deploy Redis
kubectl apply -f 04-redis.yaml

# Wait for Redis
kubectl wait --for=condition=ready pod -l app=redis -n ecommerce --timeout=300s

# 6. Deploy Auth Service (MUST be first - fixes passwords!)
kubectl apply -f 05-auth-service.yaml

# Wait for Auth Service
kubectl wait --for=condition=ready pod -l app=auth-service -n ecommerce --timeout=300s

# Check if passwords were fixed
kubectl logs -l app=auth-service -n ecommerce | grep "Fixed passwords"
# Should see: ✅ Fixed passwords for 5 seeded users

# 7. Deploy all other microservices
kubectl apply -f 06-microservices.yaml

# 8. Deploy API Gateway
kubectl apply -f 07-api-gateway.yaml

# 9. Deploy Frontend
kubectl apply -f 08-frontend.yaml

# 10. Deploy Ingress (for external access)
kubectl apply -f 09-ingress.yaml

# 11. Deploy Autoscalers (optional but recommended)
kubectl apply -f 10-hpa.yaml
```

---

## 🔍 **STEP 4: Verify Deployment**

### **Check All Pods**
```bash
kubectl get pods -n ecommerce

# Should see all pods Running:
# NAME                                READY   STATUS    RESTARTS
# postgres-0                          1/1     Running   0
# redis-0                             1/1     Running   0
# auth-service-xxx                    1/1     Running   0
# user-service-xxx                    1/1     Running   0
# product-service-xxx                 1/1     Running   0
# ... (all services)
```

### **Check Services**
```bash
kubectl get svc -n ecommerce
```

### **Check Ingress**
```bash
kubectl get ingress -n ecommerce
```

### **Verify Database Seeding**
```bash
# Connect to PostgreSQL
kubectl exec -it postgres-0 -n ecommerce -- psql -U ecommerce

# Check users
SELECT email, first_name, last_name, role FROM users;

# Should see:
# admin@ecommerce.com | Admin | User  | admin
# john@example.com    | John  | Doe   | user
# jane@example.com    | Jane  | Smith | user
# bob@example.com     | Bob   | Johnson | user
# alice@example.com   | Alice | Williams | user

# Check products
SELECT id, name, price, category FROM products;

# Exit
\q
```

### **Test Auth Service Password Fix**
```bash
# View auth service logs
kubectl logs -l app=auth-service -n ecommerce | grep -A 5 "Fixed passwords"

# Should see:
# ✅ Fixed passwords for 5 seeded users: [
#   { email: 'admin@ecommerce.com' },
#   { email: 'john@example.com' },
#   ...
# ]
```

---

## 🌐 **STEP 5: Access the Application**

### **Option A: Using Ingress (Recommended)**

If you have Ingress Controller installed:

1. Get Ingress IP:
```bash
kubectl get ingress -n ecommerce
```

2. Add to `/etc/hosts` (or use your actual domain):
```bash
# Get the EXTERNAL-IP
INGRESS_IP=$(kubectl get ingress ecommerce-ingress -n ecommerce -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Add to hosts file
echo "$INGRESS_IP ecommerce.yourdomain.com" | sudo tee -a /etc/hosts
```

3. Access:
```
http://ecommerce.yourdomain.com
```

### **Option B: Using LoadBalancer**

If you deployed LoadBalancer services:

```bash
# Get frontend LoadBalancer IP
kubectl get svc frontend-loadbalancer -n ecommerce

# Access at the EXTERNAL-IP shown
http://<EXTERNAL-IP>
```

### **Option C: Port Forward (Development/Testing)**

```bash
# Forward frontend
kubectl port-forward svc/frontend 8080:80 -n ecommerce

# Forward API Gateway (in another terminal)
kubectl port-forward svc/api-gateway 3000:3000 -n ecommerce

# Access at:
http://localhost:8080
```

---

## 🔐 **STEP 6: Test Seeded Users**

All users have password: `123456`

```
Admin Account:
  Email: admin@ecommerce.com
  Password: 123456
  Access: Full admin panel

Test Users:
  john@example.com / 123456
  jane@example.com / 123456
  bob@example.com / 123456
  alice@example.com / 123456
```

---

## 📊 **Monitoring & Debugging**

### **View Logs**
```bash
# All pods in namespace
kubectl logs -l app=auth-service -n ecommerce -f

# Specific pod
kubectl logs <pod-name> -n ecommerce

# Previous crashed pod
kubectl logs <pod-name> -n ecommerce --previous
```

### **Exec into Pod**
```bash
# PostgreSQL
kubectl exec -it postgres-0 -n ecommerce -- /bin/sh

# Redis
kubectl exec -it redis-0 -n ecommerce -- redis-cli

# Any service
kubectl exec -it <pod-name> -n ecommerce -- /bin/sh
```

### **Check Pod Events**
```bash
kubectl describe pod <pod-name> -n ecommerce
```

### **Check Resource Usage**
```bash
kubectl top pods -n ecommerce
kubectl top nodes
```

---

## 🔄 **Updating Deployments**

### **Update Service Image**
```bash
# Build new image
docker build -t $REGISTRY/ecommerce-auth-service:v2 ./services/auth-service
docker push $REGISTRY/ecommerce-auth-service:v2

# Update deployment
kubectl set image deployment/auth-service auth-service=$REGISTRY/ecommerce-auth-service:v2 -n ecommerce

# OR edit directly
kubectl edit deployment auth-service -n ecommerce
```

### **Rollback Deployment**
```bash
kubectl rollout undo deployment/auth-service -n ecommerce
```

### **Check Rollout Status**
```bash
kubectl rollout status deployment/auth-service -n ecommerce
```

---

## 🗑️ **Clean Up / Fresh Start**

### **Delete Everything**
```bash
kubectl delete namespace ecommerce
```

### **Delete Just Data (Re-seed on Next Deploy)**
```bash
# Delete PVCs to wipe database
kubectl delete pvc postgres-pvc -n ecommerce
kubectl delete pvc redis-pvc -n ecommerce

# Restart PostgreSQL to trigger re-initialization
kubectl delete pod postgres-0 -n ecommerce
```

---

## 🔒 **Production Checklist**

Before going to production:

- [ ] Change `JWT_SECRET` in secrets.yaml (use `openssl rand -base64 32`)
- [ ] Change PostgreSQL password
- [ ] Set up real domain and SSL/TLS (cert-manager + Let's Encrypt)
- [ ] Configure resource limits based on load testing
- [ ] Set up monitoring (Prometheus + Grafana)
- [ ] Set up log aggregation (ELK or Loki)
- [ ] Configure backups for PostgreSQL
- [ ] Set up CI/CD pipeline
- [ ] Enable network policies for security
- [ ] Configure pod security policies
- [ ] Set up alerts for pod failures

---

## 🎯 **Quick Deploy Script**

Save as `deploy.sh`:

```bash
#!/bin/bash
set -e

echo "Deploying LuxeCart E-Commerce to Kubernetes..."

kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-configmap-db-init.yaml
kubectl apply -f k8s/02-secrets.yaml
kubectl apply -f k8s/03-postgres.yaml

echo "Waiting for PostgreSQL..."
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=300s

kubectl apply -f k8s/04-redis.yaml

echo "Waiting for Redis..."
kubectl wait --for=condition=ready pod -l app=redis -n ecommerce --timeout=300s

kubectl apply -f k8s/05-auth-service.yaml

echo "Waiting for Auth Service to fix passwords..."
sleep 30

kubectl apply -f k8s/06-microservices.yaml
kubectl apply -f k8s/07-api-gateway.yaml
kubectl apply -f k8s/08-frontend.yaml
kubectl apply -f k8s/09-ingress.yaml
kubectl apply -f k8s/10-hpa.yaml

echo "✅ Deployment complete!"
echo "Check status: kubectl get pods -n ecommerce"
```

---

## 📞 **Support**

For issues:
1. Check pod logs: `kubectl logs <pod-name> -n ecommerce`
2. Check events: `kubectl get events -n ecommerce`
3. Verify secrets are correct
4. Ensure images are accessible from your cluster
