variable "bucket_id" {
    description = "ID of bucket used by youtube integration service for storage"
    type = string
}

variable "runtime" {
    description = "Python runtime of youtube integration service"
    type = string
}

variable "timeout" {
    description = "The amount of time that Lambda allows a function to run before stopping it. The default is 3 seconds. The maximum allowed value is 900 seconds."
    type = string
}

variable "bucket_arn" {
    description = "ARN of bucket used by youtube integration service for storage"
    type = string
}


variable "queue_arn" {
    description = "ARN of the queue used to receive events from"
    type = string
}