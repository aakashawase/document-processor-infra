terraform {
  source = "../../../modules/service-base"
}

remote_state {
  backend = "s3"
  config = {
    bucket = "terraform-state-ACCOUNT_ID"
    key    = "document-processor/staging/terraform.tfstate"
    region = "us-east-1"
  }
}

inputs = {
  # Service configuration
  service_name = "document-processor"
  environment  = "staging"

  # AWS configuration
  aws_account_id = "123456789012"  # Replace with AWS account ID
  aws_region     = "us-east-1"     # Replace with region

  # EKS OIDC configuration
  eks_oidc_id = "EXAMPLED539D4633E53DE1B71EXAMPLE"  # Replace with EKS OIDC ID

  # Kubernetes configuration
  kubernetes_namespace       = "document-processor"
  kubernetes_service_account = "document-processor-sa"

  # S3 configuration
  s3_prefix = "documents/*"
}

