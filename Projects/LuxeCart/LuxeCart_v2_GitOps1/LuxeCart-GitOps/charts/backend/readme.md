✅ HOW TO DEPLOY
KIND (safe, minimal)
    helm install luxecart ./luxecart -f values.yaml -f values-kind.yaml

EKS (full production)
    helm install luxecart ./luxecart -f values.yaml -f values-eks.yaml



🚨 Critical Production Reality (You Need to Know)
1. HPA WILL NOT WORK unless:
Metrics server is installed
Source: Kubernetes official docs
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/

2. Ingress WILL NOT WORK on EKS unless:
AWS Load Balancer Controller is installed
Source: AWS docs
https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html

3. PDB requires:
Multiple replicas (otherwise useless)
Source: Kubernetes docs
https://kubernetes.io/docs/concepts/workloads/pods/disruptions/























