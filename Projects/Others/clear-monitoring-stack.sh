#!/usr/bin/env bash
set -euo pipefail

echo "=============================="
echo " Removing Monitoring Stack"
echo "=============================="

# 1. Helm releases
helm uninstall kube-prometheus -n observability 2>/dev/null || true
helm uninstall kube-prometheus -n monitoring 2>/dev/null || true

# 2. ClusterRoles
kubectl get clusterroles \
  | grep -E 'kube-prometheus|prometheus|monitoring' || true \
  | awk '{print $1}' \
  | xargs -r kubectl delete clusterrole

# 3. ClusterRoleBindings
kubectl get clusterrolebindings \
  | grep -E 'kube-prometheus|prometheus|monitoring' || true \
  | awk '{print $1}' \
  | xargs -r kubectl delete clusterrolebinding

# 4. kube-system Services
kubectl get svc -n kube-system \
  | grep -E 'kube-prometheus|prometheus|monitoring' || true \
  | awk '{print $1}' \
  | xargs -r kubectl delete svc -n kube-system

# 5. Mutating webhooks
kubectl get mutatingwebhookconfigurations \
  | grep -E 'prometheus|monitoring' || true \
  | awk '{print $1}' \
  | xargs -r kubectl delete mutatingwebhookconfiguration

# 6. Validating webhooks
kubectl get validatingwebhookconfigurations \
  | grep -E 'prometheus|monitoring' || true \
  | awk '{print $1}' \
  | xargs -r kubectl delete validatingwebhookconfiguration

# 7. ALL Prometheus Operator CRDs (legacy + agent-era)
kubectl get crds \
  | grep monitoring.coreos.com || true \
  | awk '{print $1}' \
  | xargs -r kubectl delete crd


kubectl patch crd prometheusagents.monitoring.coreos.com \
  --type=merge \
  -p '{"metadata":{"finalizers":[]}}'

kubectl patch crd scrapeconfigs.monitoring.coreos.com \
  --type=merge \
  -p '{"metadata":{"finalizers":[]}}'

kubectl delete crd prometheusagents.monitoring.coreos.com
kubectl delete crd scrapeconfigs.monitoring.coreos.com


echo "=============================="
echo " Removing Namespaces"
echo "=============================="

kubectl delete namespace observability --ignore-not-found
kubectl delete namespace monitoring --ignore-not-found
kubectl delete namespace xxx2 --ignore-not-found
kubectl delete namespace shopsphere --ignore-not-found



echo "=============================="
echo " Verification (MUST BE EMPTY)"
echo "=============================="

kubectl get crds | grep monitoring.coreos.com || true
kubectl get clusterroles | grep -E 'prometheus|monitoring' || true
kubectl get clusterrolebindings | grep -E 'prometheus|monitoring' || true
kubectl get svc -A | grep prometheus || true
kubectl get validatingwebhookconfigurations | grep prometheus || true
kubectl get mutatingwebhookconfigurations | grep prometheus || true
helm list -A | grep prometheus || true

echo "✔ Cluster cleanup complete"
