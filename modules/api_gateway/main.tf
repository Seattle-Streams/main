resource "aws_api_gateway_rest_api" "messageAPI" {
  name        = "${var.name}"
  description = "${var.description}"
}

resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "aws_api_gateway_deployment" "messages_deployment" {
  depends_on = ["null_resource.dependency_getter"]

  rest_api_id = "${aws_api_gateway_rest_api.messageAPI.id}"
  stage_name  = "v1"
  description = "Initial deployment"
}
