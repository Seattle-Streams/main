resource "aws_iam_policy" "logging_policy" {
  name        = "${var.name}_log_policy"
  description = "IAM policy for logging to CloudWatch"

  policy = "${data.aws_iam_policy_document.log_policy.json}"
}

data "aws_iam_policy_document" "log_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${var.region}:${var.account_id}:*"]
  }
}
