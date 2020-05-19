resource "aws_codebuild_project" "build" {
  name         = "${var.name}"
  description  = "${var.description}"
  service_role = "${aws_iam_role.codebuild_execution_role.arn}"

  artifacts {
    type      = "S3"
    location  = "${var.bucket_name}"
    packaging = "ZIP"
    path      = "${var.bucket_path}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    type            = "GITHUB"
    buildspec       = "${var.build_path}/buildspec.yml"
    location        = "${var.source_url}" //https://github.com/Seattle-Streams/python.git
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
    report_build_status = true
  }

  source_version = "dev"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_codebuild_webhook" "codebuild_webhook" {
  project_name = "${aws_codebuild_project.build.name}"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "HEAD_REF"
      pattern = "dev"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "${var.build_path}"
    }
  }
}

resource "aws_codebuild_source_credential" "credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "${var.token}"
}

resource "aws_iam_role" "codebuild_execution_role" {
  name = "${var.name}_role"

  assume_role_policy = "${data.aws_iam_policy_document.codebuild_execution_role.json}"
}

data "aws_iam_policy_document" "codebuild_execution_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

module "codebuild_logs" {
  source = "../policies"

  actions     = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
  description = "IAM policy for codebuild logging to CloudWatch"
  effect      = "Allow"
  name        = "codebuild_logs"
  resources   = "arn:aws:logs:${var.region}:${var.account_id}:*"
}

module "codebuild_ec2_policies" {
  source = "../policies"

  actions = [
    "ec2:CreateNetworkInterface",
    "ec2:DescribeDhcpOptions",
    "ec2:DescribeNetworkInterfaces",
    "ec2:DeleteNetworkInterface",
    "ec2:DescribeSubnets",
    "ec2:DescribeSecurityGroups",
    "ec2:DescribeVpcs"
  ]
  description = "IAM policy for codebuild managing ec2 properties"
  effect      = "Allow"
  name        = "codebuild_ec2_policies"
  resources   = "arn:aws:ec2:${var.region}:${var.account_id}:*"
}

module "codebuild_s3_access" {
  source = "../policies"

  actions     = ["s3:PutObject", "s3:GetObject"]
  description = "IAM policy for codebuild accessing to S3"
  effect      = "Allow"
  name        = "codebuild_s3_access"
  resources   = "${var.process_messages_bucket_arn}/*"
}

module "update_lambda" {
  source = "../policies"

  actions     = ["lambda:UpdateFunctionCode", "lambda:PublishVersion", "lambda:UpdateAlias"]
  description = "IAM policy for updating lambda function code"
  effect      = "Allow"
  name        = "codebuild_update_lambda"
  resources   = "arn:aws:lambda:${var.region}:${var.account_id}:function:*"
}

resource "aws_iam_role_policy_attachment" "worker_s3_attachment" {
  role       = "${aws_iam_role.codebuild_execution_role.name}"
  policy_arn = "${module.codebuild_s3_access.arn}"
}

resource "aws_iam_role_policy_attachment" "worker_lambda_attachment" {
  role       = "${aws_iam_role.codebuild_execution_role.name}"
  policy_arn = "${module.update_lambda.arn}"
}
