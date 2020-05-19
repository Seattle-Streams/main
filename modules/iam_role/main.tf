resource "aws_iam_role" "execution_role" {
  name               = "${var.name}_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["${var.identifiers}"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole", ]
  }
}
