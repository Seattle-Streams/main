resource "aws_lambda_function" "twilio_lambda" {
  function_name = "twilio_lambda"

  s3_bucket = "process-messages-builds"
  s3_key    = "twilio/Integration.zip"

  role    = "${aws_iam_role.twilio_lambda_execution_role.arn}"
  handler = "Integration.ProcessMessage"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"
  environment {
    variables = {
      SQS_URL = "${var.queue_id}"
    }
  }
  depends_on = [
    "aws_iam_role_policy_attachment.lambda_logs",
  ]
}


####################################################################################################
##########################         Lambda Policies         #########################################
####################################################################################################

resource "aws_iam_role" "twilio_lambda_execution_role" {
  name               = "twilio_lambda_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_policy.json}"
}


# This is to manage the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "twilio_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.twilio_lambda.function_name}"
  retention_in_days = 30
}


# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
module "twilio_lambda_logging" {
  source = "../logging"

  name       = "twilio_lambda"
  region     = "${var.region}"
  account_id = "${var.account_id}"
}

resource "aws_iam_policy" "lambda_sending" {
  name        = "lambda_sending"
  description = "IAM policy for sending to sqs from a lambda"

  policy = "${data.aws_iam_policy_document.lambda_send_policy.json}"
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole", ]
  }
}

data "aws_iam_policy_document" "lambda_send_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      "${var.queue_arn}"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda_send" {
  role       = "${aws_iam_role.twilio_lambda_execution_role.name}"
  policy_arn = "${aws_iam_policy.lambda_sending.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.twilio_lambda_execution_role.name}"
  policy_arn = "${module.twilio_lambda_logging.arn}"
}
