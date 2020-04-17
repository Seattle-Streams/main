provider "aws" {
  shared_credentials_file = "/Users/Adrian/.aws/credentials"
  profile = "devops"
  region  = "${var.region}"
}
