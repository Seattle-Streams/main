output "id" {
  value = "${aws_sqs_queue.sms_queue.id}"
}

output "arn" {
  value = "${aws_sqs_queue.sms_queue.arn}"
}
