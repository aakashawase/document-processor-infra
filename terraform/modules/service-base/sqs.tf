# Dead-letter queue
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.service_name}-${var.environment}-dlq"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.service_name}-${var.environment}-dlq"
    Environment = var.environment
  }
}

# Main queue for job processing
resource "aws_sqs_queue" "main" {
  name                       = "${var.service_name}-${var.environment}-queue"
  message_retention_seconds  = 604800  # 7 days
  visibility_timeout_seconds = 300     # 5 minutes

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${var.service_name}-${var.environment}-queue"
    Environment = var.environment
  }
}

