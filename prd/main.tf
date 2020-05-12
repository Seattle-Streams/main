variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "region" {}

variable "runtime" {}
variable "timeout" {}

variable "process_message_method" {}

variable "jenkins" {}


locals {
  environment = "Prod"
}


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
  source = "../modules/endpoint"

  api_root_resource_id = "${module.messages_api.api_root_resource_id}"
  api_id               = "${module.messages_api.api_id}"
  http_method          = "${var.process_message_method}"
  authorization        = "NONE"
}

module "process_messages_integration" {
  source = "../modules/lambda_integration"

  api_root_resource_id     = "${module.messages_api.api_root_resource_id}"
  api_id                   = "${module.messages_api.api_id}"
  endpoint_resource_id     = "${module.process_messages_endpoint.endpoint_resource_id}"
  endpoint_http_method     = "${module.process_messages_endpoint.http_method}"
  process_message_method   = "${var.process_message_method}"
  twilio_lambda_invoke_arn = "${module.process_messages_service.lambda_invoke_arn}"
}

module "process_messages_service" {
  source  = "../modules/process_messages_service"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"
  # is it possible to get the sms_queue.arn like this 
  # or does it have to be defined as an output value for the queue module ?
  queue_arn = "${module.sms_queue.arn}"
  queue_id  = "${module.sms_queue.id}"
}


resource "aws_s3_bucket" "process-messages-builds" {
  bucket = "process-messages-builds"
  acl    = "private"

  tags = {
    Name        = "process-messages-builds"
    Environment = "Prod"
  }
}

module "sms_queue" {
  source      = "../modules/queue"
  name        = "sms_queue"
  environment = "${locals.environment}"
}

# TODO:
# - add build server module
# - add youtube_integration_service module
# - figure out if using outputs correctly (Line 72)
