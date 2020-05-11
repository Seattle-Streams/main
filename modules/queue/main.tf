resource "aws_sqs_queue" "sms_queue" {
  name             = var.name
  delay_seconds    = 0
  max_message_size = 2048
  # at least 6 times the timeout of the lamda receiving messages
  message_retention_seconds = 3600
  receive_wait_time_seconds = 0

  tags = {
    Environment = var.environment
  }
}