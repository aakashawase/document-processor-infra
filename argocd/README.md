# ArgoCD Deployment

## Applications

| Application | Environment | Sync Mode | Branch |
|-------------|-------------|-----------|--------|
| `staging/document-processor.yaml` | Staging | **Automated** | main |
| `production/document-processor.yaml` | Production | **Manual** | main |

## Apply Applications

```bash
kubectl apply -f argocd/staging/document-processor.yaml
kubectl apply -f argocd/production/document-processor.yaml
```

---

## Environment Promotion Strategy

### 1. Deploy to Staging (Automatic)

```bash
# Create feature branch
git checkout -b feature/my-change

# Make changes to charts/
git commit -am "Update deployment"
git push origin feature/my-change

# Create PR and merge to main
# Staging auto-syncs immediately
```

Staging has `automated` sync enabled — changes deploy automatically on merge.

### 2. Validate Staging

```bash
# Check deployment status
kubectl get pods -n document-processor
kubectl logs -f deployment/document-processor -n document-processor

# Run tests, verify functionality
```

### 3. Promote to Production (Manual Approval)

Production requires **manual sync** — it won't auto-deploy.

**Option A: ArgoCD CLI**
```bash
argocd app sync document-processor-production
```

**Option B: ArgoCD UI**
```
ArgoCD UI → document-processor-production → Click "Sync"
```

**Option C: kubectl**
```bash
argocd app sync document-processor-production --prune
```

### Promotion Flow

```
┌──────────┐    merge    ┌──────────┐   auto-sync   ┌─────────┐
│   PR     │ ─────────►  │   main   │ ────────────► │ STAGING │
└──────────┘             └────┬─────┘               └─────────┘
                              │                          │
                              │                     validate
                              │                          │
                              │                          ▼
                              │              ┌─────────────────┐
                              │              │  Tests Pass?    │
                              │              └────────┬────────┘
                              │                       │ yes
                              ▼                       ▼
                       ┌─────────────┐  manual   ┌────────────┐
                       │ ArgoCD UI   │ ────────► │ PRODUCTION │
                       │ Click Sync  │           └────────────┘
                       └─────────────┘
```

---

## Handle Rollbacks

### Staging (auto-heals, so use git)

```bash
git revert HEAD
git push origin main
# Staging auto-syncs to reverted state
```

### Production

**Option A: ArgoCD UI**
```
ArgoCD UI → document-processor-production → History → Rollback
```

**Option B: Sync to Previous Commit**
```bash
argocd app sync document-processor-production --revision <previous-commit-sha>
```

**Option C: Git Revert + Manual Sync**
```bash
git revert HEAD
git push origin main
argocd app sync document-processor-production
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
