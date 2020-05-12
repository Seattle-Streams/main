variable "jenkins" {
  description = "Private key for ec-2 running jenkins"
  type        = string
}

variable "process_messages_bucket_arn" {
  description = "ARN of the S3 bucket used to deploy code to"
  type        = string
}

