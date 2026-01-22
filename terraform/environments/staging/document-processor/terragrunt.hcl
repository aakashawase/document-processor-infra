terraform {
  source = "../../../modules/service-base"
}

# Uncomment for remote state (S3 backend)
# remote_state {
#   backend = "s3"
#   config = {
#     bucket = "terraform-state-ACCOUNT_ID"
#     key    = "document-processor/staging/terraform.tfstate"
#     region = "us-east-1"
#   }
# }

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "us-east-2"
}
EOF
}

inputs = {
  # Service configuration
  service_name = "document-processor"
  environment  = "staging"

  # AWS configuration
  aws_account_id = "303749412898"  # Replace with AWS account ID
  aws_region     = "us-east-2"     # Replace with region

  # EKS OIDC configuration
  eks_oidc_id = "72329768E0B3011FB23A8D5F2442312312"  # Replace with EKS OIDC ID

  # Kubernetes configuration
  kubernetes_namespace       = "document-processor"
  kubernetes_service_account = "document-processor-sa"

  # S3 configuration
  s3_prefix = "documents/*"
}

