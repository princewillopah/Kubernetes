# 🟢 SETUP CALICO IN KIND

### STEP 1: Create Cluster with the script

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: dev-cluster
networking:
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  disableDefaultCNI: true
nodes:
  - role: control-plane
    extraPortMappings:
    - containerPort: 80
      hostPort: 80
      protocol: TCP

    - containerPort: 443
      hostPort: 443
      protocol: TCP

  - role: worker
```

Create: 
```yaml
    kind create cluster --config  _1_cluster-a.yaml
```
Verify:
```yaml
kubectl get nodes
```

Expected state now: `NotReady`


---

### STEP 2: Install Calico only
Run: 
```yaml
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
```

Wait until pods are running - this will take about 8 minutes

Verify
```yaml
kubectl get pods -n kube-system | grep calico
```