output "name" {
  value = "${aws_iam_role.execution_role.name}"
}

output "arn" {
  value = "${aws_iam_role.execution_role.arn}"
}
