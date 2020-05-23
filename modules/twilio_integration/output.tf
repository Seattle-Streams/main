output "lambda_invoke_arn" {
  value = "${aws_lambda_alias.twilio_lambda_alias.invoke_arn}"
}

output "lambda_function_name" {
  value = "${aws_lambda_function.twilio_lambda.function_name}"
}
