variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., staging, production)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "eks_oidc_id" {
  description = "EKS OIDC provider ID (e.g., EXAMPLED539D4633E53DE1B71EXAMPLE)"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
}

variable "kubernetes_service_account" {
  description = "Kubernetes service account name"
  type        = string
}

variable "s3_prefix" {
  description = "S3 prefix for access control"
  type        = string
  default     = "*"
}

