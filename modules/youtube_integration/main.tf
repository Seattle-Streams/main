resource "aws_lambda_function" "youtube_lambda" {
  function_name = "youtube_lambda"

  s3_bucket = "${var.bucket_id}"
  s3_key    = "${var.s3_key}"

  role    = "${module.youtube_lambda_execution_role.arn}"
  handler = "Integration.ProcessMessage"
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

module "youtube_lambda_execution_role" {
  source = "../iam_role"

  name        = "youtube_lambda"
  identifiers = "lambda.amazonaws.com"
}
# This is to manage the CloudWatch Log Group for the Lambda Function.
resource "aws_cloudwatch_log_group" "youtube_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.youtube_lambda.function_name}"
  retention_in_days = 30
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
module "youtube_lambda_logging" {
  source = "../iam_policy"

  actions     = ["logs:CreateLogStream", "logs:PutLogEvents"]
  description = "IAM policy for lambda logging to CloudWatch"
  effect      = "Allow"
  name        = "youtube_lambda_logging"
  resources   = "arn:aws:logs:${var.region}:${var.account_id}:*"
}

module "lambda_receiving" {
  source = "../iam_policy"

  actions     = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
  description = "IAM policy for lambda receiving messages from sqs"
  effect      = "Allow"
  name        = "lambda_receiving"
  resources   = "${var.queue_arn}"
}

module "accessing_dynamo" {
  source = "../iam_policy"

  #   "dynamodb:PutItem" allows you to create new items
  actions     = ["dynamodb:GetItem", ]
  description = "IAM policy for reading items from dynamo"
  effect      = "Allow"
  name        = "accessing_dynamo"
  resources   = "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.table_name}"
}

module "lambda_accessing_s3" {
  source = "../iam_policy"

  actions     = ["s3:PutObject", "s3:GetObject"]
  description = "IAM policy for lambda reading files from s3"
  effect      = "Allow"
  name        = "lambda_accessing_s3"
  resources   = "${var.bucket_arn}/*"
}

resource "aws_iam_role_policy_attachment" "lambda_receive" {
  role       = "${module.youtube_lambda_execution_role.name}"
  policy_arn = "${module.lambda_receiving.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_access_s3" {
  role       = "${module.youtube_lambda_execution_role.name}"
  policy_arn = "${module.lambda_accessing_s3.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_access_dynamo" {
  role       = "${module.youtube_lambda_execution_role.name}"
  policy_arn = "${module.accessing_dynamo.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${module.youtube_lambda_execution_role.name}"
  policy_arn = "${module.youtube_lambda_logging.arn}"
}

####################################################################################################
##########################          SQS Resources          #########################################
####################################################################################################



# https://github.com/flosell/terraform-sqs-lambda-trigger-example/blob/master/trigger.tf
resource "aws_lambda_event_source_mapping" "sqs_message" {
  batch_size       = 1
  event_source_arn = "${var.queue_arn}"
  function_name    = "${aws_lambda_function.youtube_lambda.arn}"
  enabled          = true
}
