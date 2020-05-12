
output "api_root_resource_id" {
  value = "${aws_api_gateway_rest_api.messageAPI.root_resource_id}"
}

output "api_id" {
  value = "${aws_api_gateway_rest_api.messageAPI.id}"
}

output "resource_path" {
  value = "${aws_api_gateway_resource.resource.path}"
}
