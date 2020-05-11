# This is what creates the endpoint & path
resource "aws_api_gateway_resource" "resource" {
  path_part   = "process-message"
  parent_id   = "${var.api_root_resource_id}"
  rest_api_id = "${var.api_id}"
}

# This is what creates the method allowed for the endpoint
resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${var.api_id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "${var.http_method}"
  authorization = "${var.authorization}"
}
