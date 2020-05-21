variable "account_id" {}
variable "bucket_id" {}

variable "bucket_arn" {}

variable "handler" {}

variable "region" {}
variable "runtime" {
  description = "Python runtime of youtube integration service"
}

variable "s3_key" {}

variable "table_name" {}

variable "timeout" {
  description = "The amount of time that Lambda allows a function to run before stopping it. The default is 3 seconds. The maximum allowed value is 900 seconds."
}
