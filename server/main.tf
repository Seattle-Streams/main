variable "AWS_SECRET_ACCESS_KEY" {}
variable "AWS_ACCESS_KEY_ID" {}
variable "region" {}

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
