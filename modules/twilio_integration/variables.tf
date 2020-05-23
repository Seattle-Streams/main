variable "account_id" {}

variable "alias" {}

variable "bucket_id" {}

variable "queue_arn" {
  description = "ARN of the queue used to send messages to"
}

variable "queue_id" {
  description = "ID of the queue used to send messages to"
}

variable "region" {}
variable "runtime" {
  description = "Python runtime of youtube integration service"
}

variable "s3_key" {}
variable "timeout" {
  description = "The amount of time that Lambda allows a function to run before stopping it. The default is 3 seconds. The maximum allowed value is 900 seconds."
}
