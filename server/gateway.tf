variable "process_message_method" {}
resource "aws_api_gateway_rest_api" "messageAPI" {
  name        = "messageAPI"
  description = "This is the Civic Coffee Hour API"
}

# This will allow us to set a static domain name such as api.example.com
# TODO: Research acm certificates
# TODO: Discuss purchasing a domain name for the api & what the domain should be
# resource "aws_api_gateway_domain_name" "api_domain" {
#   domain_name     = "api.our-domain.com"
#   certificate_arn = "${aws_acm_certificate_validation.example.certificate_arn}"
# }

# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
# resource "aws_route53_record" "api" {
#   name    = "${aws_api_gateway_domain_name.api_domain.domain_name}"
#   type    = "A"
#   zone_id = "${aws_route53_zone.api.id}"

#   alias {
#     evaluate_target_health = true
#     name                   = "${aws_api_gateway_domain_name.api_domain.cloudfront_domain_name}"
#     zone_id                = "${aws_api_gateway_domain_name.api_domain.cloudfront_zone_id}"
#   }
# }

# resource "aws_route53_zone" "api" {
#   name = "${aws_api_gateway_domain_name.api_domain.domain_name}"
# }

# https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-deploy-api.html
# After adding these resources, we should be able to access the API using
# https://{api.our-domain.com}/{v1}

# This is what creates the endpoint & path
resource "aws_api_gateway_resource" "resource" {
  path_part   = "process-message"
  parent_id   = "${aws_api_gateway_rest_api.messageAPI.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.messageAPI.id}"
}

# This is what creates the method allowed for the endpoint
resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.messageAPI.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "${var.process_message_method}"
  authorization = "NONE"
}

# Links API Gateway to Twilio Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.messageAPI.id}"
  resource_id             = "${aws_api_gateway_resource.resource.id}"
  http_method             = "${aws_api_gateway_method.method.http_method}"
  integration_http_method = "${var.process_message_method}"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.twilio_lambda.invoke_arn}"
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

  rest_api_id = "${aws_api_gateway_rest_api.messageAPI.id}"
  stage_name  = "v1"
  description = "Initial deployment"
}
