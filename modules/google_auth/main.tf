resource "aws_lambda_function" "google_auth_lambda" {
  function_name = "google_auth_lambda"

  s3_bucket = "${var.bucket_id}"
  s3_key    = "${var.s3_key}"

  role    = "${module.google_auth_lambda_execution_role.arn}"
  handler = "${var.handler}"
  runtime = "${var.runtime}"
  timeout = "${var.timeout}"

  environment {
    variables = {
      BUCKET_NAME = "${var.bucket_id}"
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
  source = "../iam_policy"

  actions     = ["logs:CreateLogStream", "logs:PutLogEvents"]
  description = "IAM policy for lambda logging to CloudWatch"
  effect      = "Allow"
  name        = "google_auth_lambda_logging"
  resources   = "arn:aws:logs:${var.region}:${var.account_id}:*"
}

module "accessing_dynamo" {
  source = "../iam_policy"

  #   "dynamodb:PutItem" allows you to create new items
  actions     = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
  description = "IAM policy for reading items from dynamo"
  effect      = "Allow"
  name        = "google_auth_accessing_dynamo"
  resources   = "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.table_name}"
}

module "lambda_accessing_s3" {
  source = "../iam_policy"

  actions     = ["s3:GetObject"]
  description = "IAM policy for lambda reading files from s3"
  effect      = "Allow"
  name        = "google_auth_lambda_accessing_s3"
  resources   = "${var.bucket_arn}/*"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${module.google_auth_lambda_execution_role.name}"
  policy_arn = "${module.google_auth_lambda_logging.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_access_dynamo" {
  role       = "${module.google_auth_lambda_execution_role.name}"
  policy_arn = "${module.accessing_dynamo.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_access_s3" {
  role       = "${module.google_auth_lambda_execution_role.name}"
  policy_arn = "${module.lambda_accessing_s3.arn}"
}
