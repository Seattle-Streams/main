variable "bucket_id" {
  description = "ID of bucket used by youtube integration service for storage"
}

variable "runtime" {
  description = "Python runtime of youtube integration service"
}

variable "timeout" {
  description = "The amount of time that Lambda allows a function to run before stopping it. The default is 3 seconds. The maximum allowed value is 900 seconds."
}

variable "bucket_arn" {
  description = "ARN of bucket used by youtube integration service for storage"
}


variable "queue_arn" {
  description = "ARN of the queue used to receive events from"
}
