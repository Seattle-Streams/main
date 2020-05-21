resource "aws_lambda_function" "twilio_lambda" {
  function_name = "twilio_lambda"

  s3_bucket = "${var.bucket_id}"
  s3_key    = "${var.s3_key}"

  role    = "${module.twilio_lambda_execution_role.arn}"
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

module "twilio_lambda_execution_role" {
  source = "../iam_role"

  name        = "twilio_lambda"
  identifiers = "lambda.amazonaws.com"
}

# This is to manage the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "twilio_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.twilio_lambda.function_name}"
  retention_in_days = 30
}


# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
module "twilio_lambda_logging" {
  source = "../iam_policy"

  actions     = ["logs:CreateLogStream", "logs:PutLogEvents"]
  description = "IAM policy for lambda logging to CloudWatch"
  effect      = "Allow"
  name        = "twilio_lambda_logging"
  resources   = "arn:aws:logs:${var.region}:${var.account_id}:*"
}

module "lambda_sending" {
  source = "../iam_policy"

  actions     = ["sqs:SendMessage"]
  description = "IAM policy for sending to sqs from a lambda"
  effect      = "Allow"
  name        = "lambda_sending"
  resources   = "${var.queue_arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${module.twilio_lambda_execution_role.name}"
  policy_arn = "${module.twilio_lambda_logging.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_send" {
  role       = "${module.twilio_lambda_execution_role.name}"
  policy_arn = "${module.lambda_sending.arn}"
}
