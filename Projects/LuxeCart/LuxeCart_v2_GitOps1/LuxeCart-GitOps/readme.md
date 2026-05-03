

🟢 STEP 1 — Install ArgoCD (cluster-level)
    👉 Use official manifest (recommended for learning)
```yaml
    kubectl create namespace argocd

    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
#OR USE HELM BELOW
```
<br>
<br>

🔴 Optional: Install ArgoCD using Helm (PRODUCTION)
    If you want real production setup, use Helm:
```yaml
    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update
    helm repo ls
    kubectl create namespace argocd
    helm install argocd argo/argo-cd --namespace argocd --create-namespace
```

<br>


🟢 STEP 2 — Access ArgoCD UI
- Port-forward:
    -    `kubectl port-forward svc/argocd-server -n argocd 8080:443`
- Open:
    - ` https://localhost:8080`
- Get admin password:
    - ` kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- Login:
    ```yaml
    Username: admin
    Password: (output above)
    ```

🟢 STEP 3 — Create ROOT APP (apps/root.yaml)
    This is the brain of your GitOps system
    📁 bootstraps/argocd-install.yaml

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: luxecart-root
  namespace: argocd
spec:
  project: default

  source:
    repoURL: https://github.com/princewillopah/LuxeCart-GitOps.git
    targetRevision: main
    path: apps

  destination:
    server: https://kubernetes.default.svc
    namespace: argocd

  syncPolicy:
    automated:
      prune: true
      selfHeal: true

    syncOptions:
      - CreateNamespace=true
```
<br>

🟢 STEP 4 - push your project to github<br>
    

🟢 STEP 5 — Apply bootstrap<br>
    `kubectl apply -f bootstraps/argocd-install.yaml`
    <br>🧠 What happens next:


 ```yaml
    ArgoCD will:
        Read repo
        Look at /apps
    Discover:
        apps/infra/app.yaml
        apps/backend/app.yaml
        apps/frontend/app.yaml
        Deploy them using sync waves

```


<br>


🔥 FINAL STRUCTURE (YOU SHOULD HAVE)
```yaml
bootstraps/
  └── argocd-install.yaml   ✅ ONLY root

    apps/
      ├── backend/app.yaml
      ├── infra/app.yaml
      ├── frontend/app.yaml

```





















