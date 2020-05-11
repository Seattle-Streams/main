variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "region" {}

variable "runtime" {}
variable "timeout" {}

variable "process_message_method" {}

provider "aws" {
  profile    = "devops"
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region     = "${var.region}"
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "Seattle-Streams"

    workspaces {
      name = "main"
    }
  }
}

module "messages_api" {
  source = "../modules/gateway"

  name        = "messageAPI"
  description = "This is the Civic Coffee Hour API"
}

module "process_messages_endpoint" {
  source = "../modules/gateway/endpoint"

  api_root_resource_id = "${module.messages_api.api_root_resource_id}"
  api_id               = "${module.messages_api.api_id}"
  http_method          = "${var.process_message_method}"
  authorization        = "NONE"
}

module "processmessages-integration" {
  source = "../modules/gateway/lambda_integration"

  api_root_resource_id     = "${module.messages_api.api_root_resource_id}"
  api_id                   = "${module.messages_api.api_id}"
  endpoint_resource_id     = "${module.process_messages_endpoint.endpoint_resource_id}"
  endpoint_http_method     = "${module.process_messages_endpoint.http_method}"
  process_message_method   = "${var.process_message_method}"
  twilio_lambda_invoke_arn = "${module.processmessae.lambda_invoke_arn}"
}

