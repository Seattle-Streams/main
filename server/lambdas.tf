# Simple AWS Lambda Terraform Example
# to deploy: run `terraform apply`
# to destroy: run `terraform destroy`
variable "runtime" {}

# data "archive_file" "twilio_zip" {
#   type        = "zip"
#   output_path = "twilio_function.zip"
#   source_file = "TwilioIntegration.py"
# }

data "archive_file" "youtube_zip" {
  type        = "zip"
  source_file = "YoutubeIntegration.py"
  output_path = "youtube_function.zip"
}

data "aws_iam_policy_document" "lambda_policy" {
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

resource "aws_iam_role" "iam_lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_policy.json}"
}

# Lambdas
resource "aws_lambda_function" "twilio_lambda" {
  function_name = "twilio_lambda"

  filename = "twilio_lambda.zip"
  #   source_code_hash = "${data.archive_file.twilio_zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_lambda_execution_role.arn}"
  handler = "TwilioIntegration.ProcessMessage"
  runtime = "${var.runtime}"
  #   timeout = "${var.timeout}"
  environment {
    variables = {
      SQS_URL = "${aws_sqs_queue.sms_queue.id}"
    }
  }
  depends_on = [
    "aws_iam_role_policy_attachment.lambda_logs",
    "aws_sqs_queue.sms_queue"
  ]
}

resource "aws_lambda_function" "youtube_lambda" {
  function_name = "youtube_lambda"

  filename         = "${data.archive_file.youtube_zip.output_path}"
  source_code_hash = "${data.archive_file.youtube_zip.output_base64sha256}"

  role    = "${aws_iam_role.iam_lambda_execution_role.arn}"
  handler = "YoutubeIntegration.ProcessMessage"
  runtime = "${var.runtime}"
  #   timeout = "${var.timeout}"
  depends_on = [
    "aws_iam_role_policy_attachment.lambda_logs",
  ]
}

# resource "aws_lambda_event_source_mapping" "sqs_message" {
#   event_source_arn = "${aws_sqs_queue.sqs_queue_test.arn}"
#   function_name    = "${aws_lambda_function.youtube_lambda.arn}"
# }


# This is to manage the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "twilio_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.twilio_lambda.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "youtube_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.youtube_lambda.function_name}"
  retention_in_days = 30
}

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
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_lambda_execution_role.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

resource "aws_sqs_queue" "sms_queue" {
  name                      = "sms_queue"
  delay_seconds             = 0
  max_message_size          = 2048
  message_retention_seconds = 3600
  receive_wait_time_seconds = 0

  tags = {
    Environment = "production"
  }
}
