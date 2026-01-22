# IAM Role for Kubernetes Service Account (IRSA)
resource "aws_iam_role" "service_role" {
  name = "${var.service_name}-${var.environment}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.eks_oidc_provider_url}:sub" = "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account}"
            "${local.eks_oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# S3 access policy
resource "aws_iam_role_policy" "s3_access" {
  name = "${var.service_name}-s3-access"
  role = aws_iam_role.service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.documents.arn,
          "${aws_s3_bucket.documents.arn}/${var.s3_prefix}"
        ]
      }
    ]
  })
}

# SQS access policy
resource "aws_iam_role_policy" "sqs_access" {
  name = "${var.service_name}-sqs-access"
  role = aws_iam_role.service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          aws_sqs_queue.main.arn,
          aws_sqs_queue.dlq.arn
        ]
      }
    ]
  })
}

# CloudWatch Logs access policy
resource "aws_iam_role_policy" "cloudwatch_logs_access" {
  name = "${var.service_name}-cloudwatch-logs-access"
  role = aws_iam_role.service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.main.arn}:*"
      }
    ]
  })
}

