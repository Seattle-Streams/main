# Links API Gateway to Twilio Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = "${var.api_id}"
  resource_id             = "${var.endpoint_resource_id}"
  http_method             = "${var.endpoint_http_method}"
  integration_http_method = "${var.endpoint_http_method}"
  type                    = "AWS_PROXY"
  uri                     = "${var.twilio_lambda_invoke_arn}"
}

# This is used to get the account_id required for the lambda invokation permission below
# Found here: https://www.terraform.io/docs/providers/aws/d/caller_identity.html
data "aws_caller_identity" "current" {}

# Allows Gateway to invoke our first Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.twilio_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  # var.accountId is going to cause us some troubles :(
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.messageAPI.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_api_gateway_deployment" "messages_deployment" {
  depends_on = ["aws_api_gateway_integration.lambda_integration"]

  rest_api_id = "${var.api_id}"
  stage_name  = "v1"
  description = "Initial deployment"
}
