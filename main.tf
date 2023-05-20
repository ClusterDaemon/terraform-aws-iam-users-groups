# vim: tabstop=2 shiftwidth=2 expandtab
terraform {
  required_version = "~>1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}
