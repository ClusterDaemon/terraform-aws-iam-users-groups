# vim: tabstop=2 shiftwidth=2 expandtab
terraform {
  required_version = "~> 1.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.65"
    }
    http = {
      source = "hashicorp/http"
      version = "3.3.0"
    }
    external = {
      source = "hashicorp/external"
      version = "2.3.1"
    }
  }
}

locals {
  tags = merge({ Name = var.name }, var.tags)

  pgp_key = (
    var.pgp.public_key_base64 != "" ?
    var.pgp.public_key_base64 :
    format("keybase:%s", var.pgp.keybase_username)
  )
}

resource "aws_iam_user" "this" {
  name = var.name
  path = var.path

  tags = local.tags
}

resource "aws_iam_user_group_membership" "this" {
  user   = var.name
  groups = var.groups
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = toset(var.policy_arns)

  user       = aws_iam_user.this.name
  policy_arn = each.value
}

resource "aws_iam_user_policy" "this" {
  count = var.policy != "" ? 1 : 0

  name   = "Inline"
  user   = aws_iam_user.this.name
  policy = var.policy
}

resource "aws_iam_user_login_profile" "this" {
  count = var.console_password.generate_password ? 1 : 0

  user                    = aws_iam_user.this.name
  password_length         = var.console_password.password_length
  password_reset_required = var.console_password.password_reset_required
  pgp_key                 = local.pgp_key
}

resource "aws_iam_access_key" "this" {
  for_each = { for key in var.access_keys : key.name => key }

  user    = aws_iam_user.this.name
  status  = each.value.status
  pgp_key = local.pgp_key
}

resource "aws_iam_virtual_mfa_device" "this" {
  count = var.mfa_enabled ? 1 : 0

  virtual_mfa_device_name = aws_iam_user.this.name
  path                    = var.path

  tags = local.tags
}

data "http" "keybase" {
  count = var.pgp.public_key_base64 == "" && var.pgp.keybase_username != "" ? 1 : 0

  url = format(
    "https://keybase.io/_/api/1.0/user/lookup.json?usernames=%s",
    var.pgp.keybase_username
  )

  lifecycle {
    postcondition {
      condition     = contains([0, 200, 201, 204], self.status_code)
      error_message = "Keybase returned an invalid status. Check keybase and the network path."
    }
  }
}

data "external" "encrypt_and_encode_mfa" {
  for_each = var.mfa_enabled ? { qr_code_png = "qr_code_png", base_32_string_seed = "base_32_string_seed" } : {}

  program = [
    format("%s/scripts/encrypt-and-encode.sh", path.module),

    (
      var.pgp.public_key_base64 != "" ?
      var.pgp.public_key_base64 :
      jsondecode(join("", data.http.keybase[*].response_body)).them[0].public_keys.primary.bundle
    ),

    base64encode(aws_iam_virtual_mfa_device.this[0][each.value])
  ]
}
