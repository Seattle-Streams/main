# Jenkins EC2
resource "aws_instance" "server" {
  ami             = "ami-4b32be2b"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.allow_http.name}"]
}


resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow SSH and HTTP inbound traffic"


  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "http"
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "ssh"
  }
}

// Jenkins slave instance profile
# resource "aws_iam_instance_profile" "worker_profile" {
#   name = "JenkinsWorkerProfile"
#   role = "${aws_iam_role.worker_role.name}"
# }

# resource "aws_iam_role" "worker_role" {
#   name = "JenkinsBuildRole"
#   path = "/"

#   assume_role_policy = "${data.aws_iam_policy.worker_execution.json}"
# }

# data "aws_iam_policy" "worker_execution" {
#   statement {
#     effect = "Allow"

#     principals {
#       identifiers = ["ec2.amazonaws.com"]
#       type        = "Service"
#     }

#     actions = ["sts:AssumeRole", ]
#   }
# }

# resource "aws_iam_policy" "s3_policy" {
#   name = "PushToS3Policy"
#   path = "/"

#   policy = "${data.aws_iam_policy_document.update_s3.json}"
# }

# data "aws_iam_policy_document" "update_s3" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "s3:PutObject",
#       "s3:GetObject"
#     ]
#     resources = ["${aws_s3_bucket.bucket.arn}/*", ]
#   }
# }

# resource "aws_iam_policy" "lambda_policy" {
#   name = "DeployLambdaPolicy"
#   path = "/"

#   policy = "${data.aws_iam_policy.update_lambda.json}"
# }


# data "aws_iam_policy_document" "update_lambda" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "lambda:UpdateFunctionCode",
#       "lambda:PublishVersion",
#       "lambda:UpdateAlias"
#     ]
#     resources = ["*"]
#   }
# }


# resource "aws_iam_role_policy_attachment" "worker_s3_attachment" {
#   role       = "${aws_iam_role.worker_role.name}"
#   policy_arn = "${aws_iam_policy.s3_policy.arn}"
# }

# resource "aws_iam_role_policy_attachment" "worker_lambda_attachment" {
#   role       = "${aws_iam_role.worker_role.name}"
#   policy_arn = "${aws_iam_policy.lambda_policy.arn}"
# }
