# Document Processor Helm Chart

Deploys the document processor service to Kubernetes with IRSA, autoscaling, and monitoring.

## Components

- **Deployment** - Pods with security context, probes, resource limits
- **ServiceAccount** - IRSA-enabled for AWS access
- **ConfigMap** - S3, SQS, and logging configuration
- **HPA** - CPU-based autoscaling (2-10 replicas)
- **PDB** - Ensures availability during disruptions
- **ServiceMonitor** - Prometheus metrics scraping
- **PrometheusRule** - Alerts for errors, queue depth, restarts

## Deploy

```bash
# Staging
helm install document-processor . -f values-staging.yaml -n document-processor --create-namespace

# Production
helm install document-processor . -f values-production.yaml -n document-processor --create-namespace
```

## Upgrade

```bash
helm upgrade document-processor . -f values-staging.yaml -n document-processor
```

## Configuration

Update `values-staging.yaml` or `values-production.yaml` with:
- `serviceAccount.roleArn` - IAM role ARN from Terraform output
- `config.s3BucketName` - S3 bucket name from Terraform output
- `config.sqsQueueUrl` - SQS queue URL from Terraform output

## Package Chart

```bash
# Lint chart
helm lint .

# Package chart
helm package .
# Output: document-processor-1.0.0.tgz
```

## Push to Registry

**OCI Registry (ECR):**
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Push chart
helm push document-processor-1.0.0.tgz oci://ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/charts
```

**ChartMuseum:**
```bash
helm cm-push document-processor-1.0.0.tgz my-chartmuseum-repo
```

**GitHub Pages / S3:**
```bash
# Generate index
helm repo index . --url https://my-charts-bucket.s3.amazonaws.com

# Upload to S3
aws s3 cp document-processor-1.0.0.tgz s3://my-charts-bucket/
aws s3 cp index.yaml s3://my-charts-bucket/
```

## Install from Registry

```bash
# Add repo (if using ChartMuseum/S3)
helm repo add my-repo https://my-charts-bucket.s3.amazonaws.com
helm repo update

# Install from OCI
helm install document-processor oci://ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/charts/document-processor --version 1.0.0

# Install from repo
helm install document-processor my-repo/document-processor -f values-staging.yaml -n document-processor

