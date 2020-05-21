resource "aws_sqs_queue" "sms_queue" {
  name                      = "${var.Name}"
  delay_seconds             = "${var.delay_seconds}"
  max_message_size          = "${var.max_message_size}"
  message_retention_seconds = "${var.message_retention_seconds}" // at least 6 times the timeout of the lamda receiving messages
  receive_wait_time_seconds = "${var.receive_wait_time_seconds}"

  tags = {
    Environment = "${var.Environment}"
  }
}
