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

# data "aws_caller_identity" "current" {}

# variable "account_id" {
#   default = "${data.aws_caller_identity.current.account_id}"
# }
