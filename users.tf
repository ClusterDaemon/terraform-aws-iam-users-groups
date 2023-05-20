# vim: tabstop=2 shiftwidth=2 expandtab
locals {
  users = var.users != tolist([]) ? { for user in var.users : user.name => user } : {}
  groups = var.groups != tolist([]) ? { for group in var.groups : group.name => group } : {}
}

resource "aws_iam_user" "this" {
  for_each = local.users

  name = each.value.name
  path = each.value.path
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = {
    for attachment in [
      for user in local.users : setproduct([ user.name ], user.policy_arns)
    ] : format("%s-%s", attachment[0], attachment[1]) => {
      user       = attachment[0]
      policy_arn = attachment[1]
    }
  }
  
  user       = each.value.group
  policy_arn = each.value.policy_arn
}

resource "aws_iam_user_policy" "this" {
  for_each = { for name, attributes in local.users : name => attributes if contains(keys(attributes), "policy") }

  name = each.value.name
  user = each.value.name

  policy = jsonencode(each.value.policy)
}

resource "aws_iam_user_login_profile" "this" {
  for_each = {
    for name, attributes in local.users : name => attributes if attributes.console_password.generate_password
  }

  user = each.value.name

  pgp_key = each.value.pgp_public_key

  password_length         = each.value.console_password.password_length
  password_reset_required = each.value.console_password.password_reset_required
}

resource "aws_iam_access_key" "this" {
  for_each = {
    for keys in [
      for name, attributes in local.users : setproduct([ name ], lookup(attributes, "access_keys", []))
    ] : format("%s-%s", keys[0], keys[1]) => {
      name = keys[0]
      status = keys[1]
    }
  }

  user = each.value.name

  pgp_key = each.value.pgp_public_key

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_virtual_mfa_device" "this" {
  for_each = {
    for name, attributes in local.users : name => attributes if attributes.enable_mfa
  }

  virtual_mfa_device_name = each.value.name
  path                    = each.value.path
}
