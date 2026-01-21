# Service Base Module
# Creates AWS resources for a Kubernetes service with IRSA
#
# Resources created:
# - IAM Role with IRSA trust policy (iam.tf)
# - S3 Bucket with lifecycle policy (s3.tf)
# - SQS Queue with DLQ (sqs.tf)
# - CloudWatch Log Group (cloudwatch.tf)

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  eks_oidc_provider_url = "oidc.eks.${var.aws_region}.amazonaws.com/id/${var.eks_oidc_id}"
  eks_oidc_provider_arn = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${local.eks_oidc_provider_url}"
}
