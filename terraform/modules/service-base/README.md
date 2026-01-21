# Service Base Module

Creates AWS resources for a Kubernetes service with IRSA (IAM Roles for Service Accounts).

## Resources Created

- **IAM Role** - IRSA-enabled role with policies for S3, SQS, CloudWatch
- **S3 Bucket** - Versioned, encrypted, with lifecycle policy (IA after 90 days, delete after 365)
- **SQS Queue** - Main queue + dead-letter queue (3 retries)
- **CloudWatch Log Group** - 30 day retention

## Usage with Terragrunt

```hcl
# terragrunt.hcl
terraform {
  source = "../../../modules/service-base"
}

inputs = {
  service_name               = "document-processor"
  environment                = "staging"
  aws_account_id             = "123456789012"
  aws_region                 = "us-east-1"
  eks_oidc_id                = "EXAMPLED539D4633E53DE1B71EXAMPLE"
  kubernetes_namespace       = "document-processor"
  kubernetes_service_account = "document-processor-sa"
  s3_prefix                  = "documents/*"
}
```

## Apply

```bash
cd terraform/environments/staging/document-processor
terragrunt init
terragrunt plan
terragrunt apply -auto-approve
```

## Outputs

| Output | Description |
|--------|-------------|
| `iam_role_arn` | IAM role ARN for ServiceAccount annotation |
| `s3_bucket_name` | S3 bucket name |
| `sqs_queue_url` | Main SQS queue URL |
| `log_group_name` | CloudWatch log group name |

