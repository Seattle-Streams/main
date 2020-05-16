resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "${var.acl}"

  tags = {
    Name        = "${var.tag_name}"
    Environment = "${var.environment}"
  }
}
