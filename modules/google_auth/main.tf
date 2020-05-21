resource "aws_lambda_function" "google_auth_lambda" {
  function_name = "google_auth_lambda"

  s3_bucket = "${var.bucket_id}"
  s3_key    = "${var.s3_key}"

  role    = "${module.twilio_lambda_execution_role.arn}"
  handler = "Integration.ProcessMessage"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"
  environment {
    variables = {
      KEY = "${var.value}"
    }
  }
  depends_on = [
    "aws_iam_role_policy_attachment.lambda_logs",
  ]
}

####################################################################################################
##########################         Lambda Policies         #########################################
####################################################################################################

module "google_auth_lambda_execution_role" {
  source = "../iam_role"

  name        = "google_auth_lambda"
  identifiers = "lambda.amazonaws.com"
}

# This is to manage the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "google_auth_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.google_auth_lambda.function_name}"
  retention_in_days = 30
}


# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
module "google_auth_lambda_logging" {
  source = "../policies"

  actions     = ["logs:CreateLogStream", "logs:PutLogEvents"]
  description = "IAM policy for lambda logging to CloudWatch"
  effect      = "Allow"
  name        = "google_auth_lambda_logging"
  resources   = "arn:aws:logs:${var.region}:${var.account_id}:*"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${module.twilio_lambda_execution_role.name}"
  policy_arn = "${module.twilio_lambda_logging.arn}"
}
