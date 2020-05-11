resource "aws_api_gateway_rest_api" "messageAPI" {
  name        = "${var.name}"
  description = "${var.description}"
}
