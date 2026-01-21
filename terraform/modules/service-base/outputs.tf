output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.service_role.arn
}

output "iam_role_name" {
  description = "Name of the IAM role"
  value       = aws_iam_role.service_role.name
}

# S3 outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.documents.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.documents.arn
}

# SQS outputs
output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.main.url
}

output "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "sqs_dlq_url" {
  description = "URL of the dead-letter queue"
  value       = aws_sqs_queue.dlq.url
}

output "sqs_dlq_arn" {
  description = "ARN of the dead-letter queue"
  value       = aws_sqs_queue.dlq.arn
}

# CloudWatch outputs
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.main.arn
}

