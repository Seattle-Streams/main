variable "region" {
  default = "us-east-1"
}

# This is the runtime for the lambdas
variable "runtime" {
  default = "python3.8"
}

variable "timeout" {
  default = 10
}

variable "process_message_method" {
  default = "POST"
}

variable "aws_access_key" {
  default = ""
}

variable "aws_secret_key" {
  default = ""
}

