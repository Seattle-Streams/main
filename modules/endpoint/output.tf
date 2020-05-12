output "endpoint_resource_id" {
  value = "${aws_api_gateway_resource.resource.id}"
}

output "http_method" {
  value = "${aws_api_gateway_method.method.http_method}"
}
