resource "aws_sqs_queue" "sms_queue" {
  name                      = "${var.Name}"
  delay_seconds             = 0    //"${var.delay_seconds}"
  max_message_size          = 2048 //"${var.max_message_size}"
  message_retention_seconds = 3600 //"${var.message_retention_seconds}" // at least 6 times the timeout of the lamda receiving messages
  receive_wait_time_seconds = 0    //"${var.receive_wait_time_seconds}"

  tags = {
    Environment = "${var.Environment}"
  }
}
