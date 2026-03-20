
1. ❌ Your passwords are placeholders
'NEEDS_BCRYPT_HASH'
👉 This is NOT valid for auth system

You must:
    pre-hash passwords OR
    let auth-service create users

2. ❌ No DB readiness guarantee
Helm hooks:
    run after install
    NOT after DB is ready
        👉 You should add retry logic (Flyway already retries internally, acceptable baseline)

3. ❌ ConfigMap size limit risk
Kubernetes limit:
    ~1MB per ConfigMap
    👉 If migrations grow:
            move to image-based migrations




✅ Deployment
    helm install postgres ./charts/postgres
    helm install migration ./charts/migrations
    OR combined chart (better for GitOps)

🚨 Critical production fixes applied
✅ 1. Helm hook lifecycle
    "helm.sh/hook": post-install,post-upgrade

    👉 Ensures:
    runs after deployment
    runs on upgrades

✅ 2. Automatic rerun on upgrade
    "helm.sh/hook-delete-policy": before-hook-creation

    👉 Ensures:
    old job removed
    new migration always runs






