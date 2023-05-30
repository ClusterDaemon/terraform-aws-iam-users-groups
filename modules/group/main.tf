# vim: tabstop=2 shiftwidth=2 expandtab
terraform {
  required_version = ">= 0.14, < 2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65"
    }
  }
}

resource "aws_iam_group" "this" {
  name = var.name
  path = var.path
}

resource "aws_iam_group_policy_attachment" "this" {
  count = length(var.policy_arns)

  group      = aws_iam_group.this.name
  policy_arn = var.policy_arns[count.index]
}

resource "aws_iam_group_policy" "this" {
  count = var.policy != "" ? 1 : 0
  name  = aws_iam_group.this.name
  group = aws_iam_group.this.name

  policy = var.policy
}
