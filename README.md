# Document Processor Infrastructure

Infrastructure-as-Code for deploying a document processing service on AWS EKS.

## Overview

This repository contains the complete infrastructure setup for a document processor service that:
- Processes documents uploaded to S3
- Uses SQS for job queuing with dead-letter queue for failed messages
- Runs on Kubernetes (EKS) with IRSA for secure AWS access
- Includes monitoring, autoscaling, and GitOps deployment via ArgoCD

**Why this approach?**
- **Terraform + Terragrunt**: Modular, reusable infrastructure with DRY configuration
- **Helm Charts**: Templated Kubernetes manifests for multi-environment deployments
- **ArgoCD**: GitOps-based continuous deployment with self-healing
- **IRSA**: Secure AWS access without storing credentials in pods

---

## Repository Structure

```
document-processor-infra/
├── README.md
├── terraform/
│   ├── modules/
│   │   └── service-base/          # Reusable Terraform module
│   │       ├── main.tf            # Provider config + locals
│   │       ├── variables.tf       # Input variables
│   │       ├── outputs.tf         # Output values
│   │       ├── iam.tf             # IAM role + policies (IRSA)
│   │       ├── s3.tf              # S3 bucket + lifecycle
│   │       ├── sqs.tf             # SQS queue + DLQ
│   │       └── cloudwatch.tf      # Log group
│   └── environments/
│       └── staging/
│           └── document-processor/
│               └── terragrunt.hcl # Environment-specific config
├── charts/
│   └── document-processor/        # Helm chart
│       ├── Chart.yaml
│       ├── values.yaml            # Default values
│       ├── values-staging.yaml    # Staging overrides
│       ├── values-production.yaml # Production overrides
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── serviceaccount.yaml
│           ├── configmap.yaml
│           ├── hpa.yaml
│           ├── pdb.yaml
│           ├── servicemonitor.yaml
│           └── prometheusrule.yaml
└── argocd/
    ├── README.md
    ├── staging/
    │   └── document-processor.yaml
    └── production/
        └── document-processor.yaml
```

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.0 | Infrastructure provisioning |
| Terragrunt | >= 0.45 | Terraform wrapper for DRY config |
| Helm | >= 3.0 | Kubernetes package manager |
| kubectl | >= 1.24 | Kubernetes CLI |
| AWS CLI | >= 2.0 | AWS authentication |
| ArgoCD | >= 2.0 | GitOps deployment (cluster) |

**AWS Requirements:**
- EKS cluster with OIDC provider enabled
- S3 bucket for Terraform state
- IAM permissions to create resources

---

## Setup Instructions

### 1. Deploy AWS Infrastructure (Terraform)

```bash
cd terraform/environments/staging/document-processor

# Update terragrunt.hcl with your values:
# - aws_account_id
# - aws_region
# - eks_oidc_id

terragrunt init
terragrunt plan
terragrunt apply -auto-approve
```

**Outputs to note:**
- `iam_role_arn` → Use in Helm values
- `s3_bucket_name` → Use in Helm values
- `sqs_queue_url` → Use in Helm values

### 2. Update Helm Values

Edit `charts/document-processor/values-staging.yaml`:

```yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: <iam_role_arn from terraform>

config:
  s3BucketName: <s3_bucket_name from terraform>
  sqsQueueUrl: <sqs_queue_url from terraform>
```

### 3. Deploy with ArgoCD

```bash
# Apply ArgoCD application
kubectl apply -f argocd/staging/document-processor.yaml

# Monitor sync status
argocd app get document-processor-staging
```

### 4. Or Deploy with Helm (without ArgoCD)

```bash
helm install document-processor ./charts/document-processor \
  -f ./charts/document-processor/values-staging.yaml \
  -n document-processor --create-namespace
```

---

## Architecture Decisions

| Decision | Choice | Trade-off |
|----------|--------|-----------|
| **State Management** | S3 + DynamoDB locking | Centralized state, team collaboration vs. additional AWS resources |
| **IAM Authentication** | IRSA (IAM Roles for Service Accounts) | No credentials in pods, automatic rotation vs. EKS-specific |
| **Message Queue** | SQS with DLQ | Managed service, auto-retry vs. less control than self-hosted |
| **Autoscaling** | HPA on CPU (70%) | Simple, reliable vs. could use custom metrics |
| **Monitoring** | Prometheus Operator CRDs | Standard K8s monitoring vs. requires Prometheus stack |
| **Deployment** | ArgoCD GitOps | Declarative, self-healing vs. additional tooling |
| **S3 Lifecycle** | IA after 90 days, delete 365 | Cost optimization vs. data retention requirements |

---

## What I'd Improve (Given More Time)

1. **Implement KEDA** - Scale based on SQS queue depth instead of CPU
2. **Add Network Policies** - Restrict pod-to-pod communication
3. **Create production Terragrunt config** - Mirror staging setup
4. **Add CI/CD pipeline** - GitHub Actions for terraform plan/apply
5. **Implement blue-green deployments** - Argo Rollouts for safer releases
6. **Add resource quotas** - Namespace-level limits
7. **Implement cost tagging** - Better AWS cost allocation

---

## Time Spent

| Section | Time |
|---------|------|
| Terraform module (IAM, S3, SQS, CloudWatch) | ~1.5 hours |
| Helm chart (all templates + values) | ~1.5 hours |
| ArgoCD manifests + promotion strategy | ~0.5 hours |
| Documentation | ~0.5 hours |
| **Total** | **~4 hours** |

---

## Quick Reference

```bash
# Terraform
cd terraform/environments/staging/document-processor
terragrunt apply -auto-approve

# Helm
helm upgrade --install document-processor ./charts/document-processor \
  -f ./charts/document-processor/values-staging.yaml -n document-processor

# ArgoCD
kubectl apply -f argocd/staging/document-processor.yaml
argocd app sync document-processor-staging

# Rollback
argocd app rollback document-processor-staging
```

