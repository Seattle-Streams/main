output "id" {
  value = "${aws_dynamodb_table.dynamo_table.id}"
}

output "arn" {
  value = "${aws_dynamodb_table.dynamo_table.arn}"
}
