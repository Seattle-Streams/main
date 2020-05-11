variable "process_message_method" {}
resource "aws_api_gateway_rest_api" "messageAPI" {
  name        = "${var.name}"
  description = "${var.description}"
}

resource "aws_api_gateway_deployment" "messages_deployment" {
  depends_on = ["aws_api_gateway_integration.lambda_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.messageAPI.id}"
  stage_name  = "v1"
  description = "Initial deployment"
}

