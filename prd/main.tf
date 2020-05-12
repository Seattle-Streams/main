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

# Use this to get account id
data "aws_caller_identity" "current" {}

module "process_messages_proxy" {
  source = "../modules/lambda_proxy"

  account_id                  = "${data.aws_caller_identity.current.account_id}"
  api_id                      = "${module.messages_api.api_id}"
  endpoint_http_method        = "${var.process_message_method}"
  endpoint_resource_id        = "${module.process_messages_endpoint.endpoint_resource_id}"
  region                      = "${var.region}"
  resource_path               = "${module.messages_api.resource_path}"
  twilio_lambda_function_name = "${module.twilio_integration.lambda_function_name}"
  twilio_lambda_invoke_arn    = "${module.twilio_integration.lambda_invoke_arn}"
}

module "twilio_integration" {
  source = "../modules/twilio_integration"

  runtime   = "${var.runtime}"
  timeout   = "${var.timeout}"
  queue_arn = "${module.sms_queue.arn}"
  queue_id  = "${module.sms_queue.id}"
}

# Bucket for process messages service
resource "aws_s3_bucket" "process-messages-builds" {
  bucket = "process-messages-builds"
  acl    = "private"

  tags = {
    Name        = "process-messages-builds"
    Environment = "${locals.environment}"
  }
}

module "sms_queue" {
  source = "../modules/queue"

  Name        = "sms_queue"
  Environment = "${locals.environment}"
}

module "youtube_integration" {
  source = "../modules/youtube_integration"

  runtime    = "${var.runtime}"
  timeout    = "${var.timeout}"
  queue_arn  = "${module.sms_queue.arn}"
  bucket_id  = "${aws_s3_bucket.process-messages-builds.id}"
  bucket_arn = "${aws_s3_bucket.process-messages-builds.arn}"
}

module "jenkins_build_server" {
  source = "../modules/build_server"

  jenkins = "${var.jenkins}"
}
