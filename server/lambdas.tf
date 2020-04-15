# Simple AWS Lambda Terraform Example
# to deploy: run `terraform apply`
# to destroy: run `terraform destroy`

data "archive_file" "twilio_zip" {
  type        = "zip"
  source_file = "TwilioIntegration.py"
  output_path = "lambda_function.zip"
}

data "archive_file" "youtube_zip" {
  type        = "zip"
  source_file = "YoutubeIntegration.py"
  output_path = "lambda_function.zip"
}

data "aws_iam_policy_document" "send_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
    "logs:PutLogEvents"]
  }
}

data "aws_iam_policy_document" "receive_policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
    "sqs:GetQueueAttributes"]
  }
}

resource "aws_iam_role" "iam_twilio_lambda" {
  name               = "iam_twilio_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.send_policy.json}"
}

resource "aws_iam_role" "iam_youtube_lambda" {
  name               = "iam_youtube_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.receive_policy.json}"
}

# Lambdas
resource "aws_lambda_function" "twilio_lambda" {
  function_name = "twilio_lambda"

  filename         = "${data.archive_file.twilio_zip.output_path}"
  source_code_hash = "${data.archive_file.twilio_zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_twilio_lambda.arn}"
  handler = "TwilioIntegration.ProcessMessages"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"
}

resource "aws_lambda_function" "youtube_lambda" {
  function_name = "youtube_lambda"

  filename         = "${data.archive_file.twilio_zip.output_path}"
  source_code_hash = "${data.archive_file.twilio_zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_youtube_lambda.arn}"
  handler = "YoutubeIntegration.ProcessMessages"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"
}

# resource "aws_lambda_event_source_mapping" "sqs_message" {
#   event_source_arn = "${aws_sqs_queue.sqs_queue_test.arn}"
#   function_name    = "${aws_lambda_function.youtube_lambda.arn}"
# }
