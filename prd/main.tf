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
  dependencies = [
    "${module.process_messages_proxy.depended_on}",
  ]
}

module "process_messages_endpoint" {
  source = "../modules/endpoint"

  path_part            = "process-message"
  api_root_resource_id = "${module.messages_api.api_root_resource_id}"
  api_id               = "${module.messages_api.api_id}"
  http_method          = "${var.process_message_method}"
  authorization        = "NONE"
}

module "auth_endpoint" {
  source = "../modules/endpoint"

  path_part            = "auth"
  api_root_resource_id = "${module.messages_api.api_root_resource_id}"
  api_id               = "${module.messages_api.api_id}"
  http_method          = "POST"
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
  resource_path               = "${module.process_messages_endpoint.resource_path}"
  twilio_lambda_function_name = "${module.twilio_integration.lambda_function_name}"
  twilio_lambda_invoke_arn    = "${module.twilio_integration.lambda_invoke_arn}"
}

module "twilio_integration" {
  source = "../modules/twilio_integration"

  account_id = "${data.aws_caller_identity.current.account_id}"
  bucket_id  = "${module.process_messages_bucket.id}"
  queue_arn  = "${module.sms_queue.arn}"
  queue_id   = "${module.sms_queue.id}"
  region     = "${var.region}"
  runtime    = "${var.runtime}"
  s3_key     = "twilio/Integration.zip"
  timeout    = "${var.timeout}"
}

# Bucket for process messages service
module "process_messages_bucket" {
  source = "../modules/s3"

  acl         = "private"
  bucket_name = "process-messages"
  tag_name    = "process-messages"
  environment = "${local.environment}"
}

# Queue for the process messages service
module "sms_queue" {
  source = "../modules/queue"

  Name        = "sms_queue"
  Environment = "${local.environment}"
}

module "youtube_integration" {
  source = "../modules/youtube_integration"

  account_id = "${data.aws_caller_identity.current.account_id}"
  bucket_arn = "${module.process_messages_bucket.arn}"
  bucket_id  = "${module.process_messages_bucket.id}"
  queue_arn  = "${module.sms_queue.arn}"
  region     = "${var.region}"
  runtime    = "${var.runtime}"
  s3_key     = "youtube/Integration.zip"
  table_name = "${module.user_table.id}"
  timeout    = "${var.timeout}"
}

# DynamoDB table associating customers w/ 3rd party accounts req'd for integrations
module "user_table" {
  source = "../modules/dynamodb"

  billing_mode       = "PAY_PER_REQUEST"
  hash_key_attr      = "Email"
  hash_key_attr_type = "S"
  recovery_enabled   = true
  table_name         = "user"
}

# Jenkins build server builds lambda function code
module "jenkins_build_server" {
  source = "../modules/build_server"

  account_id                  = "${data.aws_caller_identity.current.account_id}"
  jenkins                     = "${var.jenkins}"
  process_messages_bucket_arn = "${module.process_messages_bucket.arn}"
  region                      = "${var.region}"
}

module "twilio_codebuild_project" {
  source = "../modules/codebuild"

  account_id  = "${data.aws_caller_identity.current}"
  bucket_name = "${module.process_messages_bucket.id}"
  bucket_path = "twilio"
  build_path  = "lambda/twilio"
  description = "Build project for the twilio lambda function"
  environment = "${local.environment}"
  name        = "twilio_build"
  region      = "${var.region}"
  source_url  = "https://github.com/Seattle-Streams/python.git"
  token       = "${var.codebuild_github_token}"
}
