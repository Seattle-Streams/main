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

    actions = ["sts:AssumeRole", ]
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

    actions = [
      "sts:AssumeRole",
    ]
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
  handler = "TwilioIntegration.ProcessMessage"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"
  depends_on = [
    "aws_iam_role_policy_attachment.lambda_logs",
  ]
}

resource "aws_lambda_function" "youtube_lambda" {
  function_name = "youtube_lambda"

  filename         = "${data.archive_file.twilio_zip.output_path}"
  source_code_hash = "${data.archive_file.twilio_zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_youtube_lambda.arn}"
  handler = "YoutubeIntegration.ProcessMessage"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"
  depends_on = [
    "aws_iam_role_policy_attachment.lambda_logs",
  ]
}

# resource "aws_lambda_event_source_mapping" "sqs_message" {
#   event_source_arn = "${aws_sqs_queue.sqs_queue_test.arn}"
#   function_name    = "${aws_lambda_function.youtube_lambda.arn}"
# }


# This is to manage the CloudWatch Log Group for the Lambda Function.
# We can skip this resource configuration, but then we need to add "logs:CreateLogGroup" 
# to the IAM policy below.
# resource "aws_cloudwatch_log_group" "lambda_log_group" {
#   name              = "/aws/lambda/${aws_lambda_function.function_name}"
#   retention_in_days = 28
# }

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = "${data.aws_iam_policy_document.log_policy.json}"
}

data "aws_iam_policy_document" "log_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_twilio_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}
