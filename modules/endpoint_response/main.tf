resource "aws_api_gateway_method_response" "response" {
  rest_api_id         = "${var.api_id}"
  resource_id         = "${var.resource_id}"
  http_method         = "${var.http_method}"
  status_code         = "${var.status_code}"
  response_parameters = { "method.response.header.Content-Type" = "text/richtext" }
}
resource "aws_api_gateway_integration_response" "integration_response" {
  rest_api_id         = "${var.api_id}"
  resource_id         = "${var.resource_id}"
  http_method         = "${var.http_method}"
  status_code         = "${var.status_code}"
  content_handling    = "${var.content_handling}"
  response_parameters = { "method.response.header.Content-Type" = "text/richtext" }
  response_templates = {
    "text/richtext" = "Message Received"
  }
}
