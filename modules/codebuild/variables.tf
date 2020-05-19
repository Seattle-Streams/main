variable "account_id" {}

variable "bucket_name" {}

variable "bucket_path" {}

variable "build_path" {}

variable "description" {}

variable "environment" {}

variable "name" {}

variable "region" {}

variable "source_url" {}

variable "token" {
  description = "The Github personal access token required for codebuild to access and build off of our repo webhooks."
}
