# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/app/${var.service_name}/${var.environment}"
  retention_in_days = 30

  tags = {
    Name        = "${var.service_name}-${var.environment}-logs"
    Environment = var.environment
  }
}

