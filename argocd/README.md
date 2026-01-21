# ArgoCD Deployment

## Applications

- `staging/document-processor.yaml` - Deploys to staging (tracks HEAD)
- `production/document-processor.yaml` - Deploys to production (tracks main branch)

## Apply Applications

```bash
kubectl apply -f argocd/staging/document-processor.yaml
kubectl apply -f argocd/production/document-processor.yaml
```

---

## Environment Promotion Strategy

### 1. Deploy to Staging First

```bash
# Push changes to feature branch
git checkout -b feature/my-change
# Make changes to charts/
git commit -am "Update deployment"
git push origin feature/my-change

# Merge to main - staging auto-syncs (tracks HEAD)
git checkout main
git merge feature/my-change
git push origin main
```

Staging ArgoCD app automatically syncs since it tracks `HEAD`.

### 2. Promote to Production After Validation

```bash
# After staging validation, production syncs from main branch
# Production app tracks 'main' branch - same as staging after merge

# For controlled releases, use git tags:
git tag v1.2.0
git push origin v1.2.0

# Update production app to track specific tag (optional)
# Change targetRevision: v1.2.0 in production/document-processor.yaml
```

### 3. Handle Rollbacks

**Option A: ArgoCD UI**
```
ArgoCD UI → Application → History → Rollback to previous sync
```

**Option B: Git Revert**
```bash
git revert HEAD
git push origin main
# ArgoCD auto-syncs to reverted state
```

**Option C: Manual Sync to Previous Revision**
```bash
argocd app sync document-processor-production --revision <previous-commit-sha>
```

**Option D: Helm Rollback (if not using ArgoCD sync)**
```bash
helm rollback document-processor -n document-processor
```

---

## Sync Waves

Resources deploy in order using `argocd.argoproj.io/sync-wave` annotation:

| Wave | Resources |
|------|-----------|
| 0 | Namespace, ConfigMap, ServiceAccount |
| 1 | Deployment, Service |
| 2 | HPA, PDB |
| 3 | ServiceMonitor, PrometheusRule |

To add sync waves to templates, add annotation:
```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "0"
```

