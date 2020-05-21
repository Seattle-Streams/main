variable "Environment" {
  description = "Dev/Stg/Prod"
}
variable "delay_seconds" {}
variable "max_message_size" {}
variable "message_retention_seconds" {}

variable "Name" {
  description = "Name of the queue"
}

variable "receive_wait_time_seconds" {}
