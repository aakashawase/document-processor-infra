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

