
resource "aws_lambda_function" "youtube_lambda" {
  function_name = "youtube_lambda"

  s3_bucket = "process-messages-builds"
  s3_key    = "youtube/Integration.zip"

  role    = "${aws_iam_role.youtube_lambda_execution_role.arn}"
  handler = "Integration.ProcessMessage"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"

  environment {
    variables = {
      BUCKET_NAME = "${aws_s3_bucket.process-messages-builds.id}"
    }
  }

  depends_on = [
    "aws_iam_role_policy_attachment.lambda_logs",
  ]
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

resource "aws_iam_role" "youtube_lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_policy.json}"
}


####################################################################################################
##########################         Lambda Policies         #########################################
####################################################################################################

# This is to manage the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "youtube_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.youtube_lambda.function_name}"
  retention_in_days = 30
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
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
  role       = "${aws_iam_role.youtube_lambda_execution_role.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}

resource "aws_iam_policy" "lambda_sending" {
  name        = "lambda_sending"
  description = "IAM policy for sending to sqs from a lambda"

  policy = "${data.aws_iam_policy_document.lambda_send_policy.json}"
}

resource "aws_iam_policy" "lambda_receiving" {
  name        = "lambda_receiving"
  description = "IAM policy for lambda receiving messages from sqs"

  policy = "${data.aws_iam_policy_document.lambda_receive_policy.json}"
}

resource "aws_iam_policy" "lambda_accessing_s3" {
  name        = "lambda_accessing_s3"
  description = "IAM policy for lambda reading files from s3"

  policy = "${data.aws_iam_policy_document.lambda_access_s3_policy.json}"
}

data "aws_iam_policy_document" "lambda_receive_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      "${aws_sqs_queue.sms_queue.arn}"
    ]
  }
}

data "aws_iam_policy_document" "lambda_access_s3_policy" {

  statement {
    effect = "Allow"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:*"
    ]
    resources = ["${aws_s3_bucket.process-messages-builds.arn}/*", ]
  }

}

resource "aws_iam_role_policy_attachment" "lambda_receive" {
  role       = "${aws_iam_role.youtube_lambda_execution_role.name}"
  policy_arn = "${aws_iam_policy.lambda_receiving.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_access_s3" {
  role       = "${aws_iam_role.youtube_lambda_execution_role.name}"
  policy_arn = "${aws_iam_policy.lambda_accessing_s3.arn}"
}



####################################################################################################
##########################          S3 Resources           #########################################
####################################################################################################

# TODO: move this into top level main
resource "aws_s3_bucket" "process-messages-builds" {
  bucket = "process-messages-builds"
  acl    = "private"

  tags = {
    Name        = "process-messages-builds"
    Environment = "Prod"
  }
}

####################################################################################################
##########################          SQS Resources          #########################################
####################################################################################################

# TODO: restructure: this goes in the top-level main

# https://github.com/flosell/terraform-sqs-lambda-trigger-example/blob/master/trigger.tf
resource "aws_lambda_event_source_mapping" "sqs_message" {
  batch_size       = 1
  event_source_arn = "${aws_sqs_queue.sms_queue.arn}"
  function_name    = "${aws_lambda_function.youtube_lambda.arn}"
  enabled          = true
}
