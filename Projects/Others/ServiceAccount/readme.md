## ServiceAccount

A ServiceAccount (SA) is an identity for pods, not humans.
When this pod talks to the Kubernetes API or cloud services — who is it?

Use cases:
   - Pod reads K8s API (list pods, configmaps, secrets)
   - Pod uses IRSA to access AWS resources
   - Pod authenticates to Vault
   - Pod talks to metrics server
   - Controllers / operators
   - CI/CD runners inside cluster

If your pod needs permissions → it must use a ServiceAccount + RBAC.


Therefore:
* Service Account: An identity for pods to interact with K8s API
* Pods use it to authenticate to K8s API or external services

<br>

Key Points:
   1. Default SA: Each namespace has a default SA.
   2. Custom SA: Create for fine-grained permissions. 
   3. Role-Based Access Control (RBAC): Bind roles to SA. 


<br>


As explain above, Every namespace has `"default ServiceAccount"`. So, If you do nothing 

`pod` → `uses default SA` → `gets default token` → `limited API access`

This is Bad practice in production:
- never rely on default SA
- always create a dedicated SA per workload


---

For example1 Run the following 
```
kubectl apply -f _1_ns.yaml && \
kubectl apply -f _2_role.yaml  && \
kubectl apply -f _3_role-binding.yaml && \
kubectl apply -f _4_pod.yaml 
```
then run the command

```
kubectl exec test-pod -- curl -s https://kubernetes.default/api/v1/pods --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
```


Expected:
- Lists pods in default namespace.


Cleanup:
```
kubectl delete pod test-pod
kubectl delete sa my-sa
kubectl delete role pod-reader
kubectl delete rolebinding read-pods
```
---
For example2:
```
./run.sh
```

#### Call Kubernetes API Using SA Token
Exec into the pod:

```
kubectl exec -n demo-service-account -it api-test -- sh
```

inside pod:
```
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

curl -s \
  --header "Authorization: Bearer $TOKEN" \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  https://kubernetes.default.svc/api/v1/namespaces/demo-service-account/pods
```

* If RBAC is correct → returns pod list JSON.
* If RBAC is wrong → 403 Forbidden

That’s your proof test.

✅ Verify ServiceAccount Is Used
```
kubectl get pod api-test -n demo-service-account -o jsonpath='{.spec.serviceAccountName}'
```
---

Example2 scrips:

`kubectl create namespace demo-service-account`

Then
```YAML

apiVersion: v1
kind: ServiceAccount
metadata:
  name: pod-reader
  namespace: demo-service-account
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-read-role
  namespace: demo-service-account
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get","list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-read-binding
  namespace: demo-service-account
subjects:
- kind: ServiceAccount
  name: pod-reader
  namespace: demo-service-account
roleRef:
  kind: Role
  name: pod-read-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: Pod
metadata:
  name: api-test
  namespace: demo-service-account
spec:
  serviceAccountName: pod-reader
  containers:
  - name: test
    image: curlimages/curl:8.5.0
    command: ["sleep","3600"]


```

