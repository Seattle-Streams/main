resource "aws_iam_policy" "policy" {
  name        = "${var.name}_policy"
  description = "${var.description}"

  policy = "${data.aws_iam_policy_document.policy_document.json}"
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    effect = "${var.effect}"

    actions   = "${var.actions}"
    resources = ["${var.resources}"]
  }
}
