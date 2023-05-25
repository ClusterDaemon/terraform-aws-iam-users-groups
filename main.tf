# vim: tabstop=2 shiftwidth=2 expandtab
terraform {
  required_version = "~>1.4"

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
  users  = var.users != tolist([]) ? { for user in var.users : user.name => user } : {}
  groups = var.groups != tolist([]) ? { for group in var.groups : group.name => group } : {}
}


#########
# Users #
#########

resource "aws_iam_user" "this" {
  for_each = local.users

  name = each.value.name
  path = each.value.path
}

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for name, attributes in local.users : name => attributes
    if attributes.groups != tolist([])
  }

  user = aws_iam_user.this[each.key].name

  # If the requested group has been defined in this module, create an implicit dependency.
  groups = [
    for group in each.value.groups : (
      contains(keys(local.groups), group) ?
      aws_iam_group.this[group].name :
      group
    )
  ]

}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = {
    for attachment in concat([], [
      for user in local.users : setproduct([user.name], user.policy_arns)
    ]...) : format("%s-%s", attachment[0], attachment[1]) => {
      user       = attachment[0]
      policy_arn = attachment[1]
    } 
  }

  user       = aws_iam_user.this[each.value.user].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_user_policy" "this" {
  for_each = {
    for name, attributes in local.users : name => attributes if attributes.policy != ""
  }

  name = each.value.name
  user = aws_iam_user.this[each.value.name].name

  policy = each.value.policy
}

resource "aws_iam_user_login_profile" "this" {
  for_each = {
    for name, attributes in local.users : name => attributes if attributes.console_password.generate_password
  }

  user                    = aws_iam_user.this[each.key].name
  password_length         = each.value.console_password.password_length
  password_reset_required = each.value.console_password.password_reset_required

  pgp_key = (
    contains(keys(each.value.pgp), "public_key_base64") ?
    each.value.pgp.public_key_base64 :
    each.value.pgp.keybase_username
  )

}

resource "aws_iam_access_key" "this" {
  for_each = {
    for keys in concat([], [
      for name, attributes in local.users : setproduct(
        [name],
        [ for key in attributes.access_keys : merge(key, { pgp = attributes.pgp }) ]
      )
    ]...) : format("%s-%s", keys[0], keys[1].name) => {
      name    = keys[0]
      status  = keys[1].status

      pgp_key = (
        contains(keys(keys[1].pgp), "public_key_base64") ?
        keys[1].pgp.public_key_base64 :
        keys[1].pgp.keybase_username
      )
    }
  }

  user    = aws_iam_user.this[each.value.name].name
  pgp_key = each.value.pgp_key
}

resource "aws_iam_virtual_mfa_device" "this" {
  for_each = {
    for name, attributes in local.users : name => attributes if attributes.enable_mfa
  }

  virtual_mfa_device_name = each.value.name
  path                    = each.value.path
}

data "http" "keybase" {
  for_each = {
    for name, attributes in local.users : name => attributes.pgp
    if alltrue([attributes.pgp.keybase_username != null, attributes.pgp.public_key_base64 == null])
  }

  url = format(
    "https://keybase.io/_/api/1.0/user/lookup.json?usernames=%s",
    each.value.keybase_username
  )
}

data "external" "encrypt_and_encode_mfa_qr" {
  for_each = {
    for name, attributes in local.users : name => merge(attributes, {
      username = attributes.pgp.keybase_username != null ? attributes.pgp.keybase_username : name

      pgp_public_key = (
        attributes.pgp.public_key_base64 != null ?
        attributes.pgp.public_key_base64 :
        base64encode(jsondecode(data.http.keybase[name].body).them[0].public_keys.primary.bundle)
      )

    })
    if attributes.enable_mfa
  }

  program = ["bash", "-c", <<-EOT
    echo '${each.value.pgp_public_key}' |\
    gpg --import --no-default-keyring --keyring ./tempkeyring.gpg ;\
    echo '${aws_iam_virtual_mfa_device.this[each.key].qr_code_png}' |\
    gpg --yes \
      --batch \
      --encrypt \
      --recipient ${each.value.username} \
      --no-default-keyring \
      --keyring ./tempkeyring.gpg |\
    base64 |\
    jq -R -s '{encrypted_file_b64: .}'
    EOT
  ]
}

##########
# Groups #
##########

resource "aws_iam_group" "this" {
  for_each = local.groups

  name = each.value.name
  path = each.value.path
}

resource "aws_iam_group_policy_attachment" "this" {
  for_each = {
    for attachment in concat([], [ for group in local.groups : setproduct([group.name], group.policy_arns)]...) :
    format("%s-%s", attachment[0], attachment[1]) => {
      group      = attachment[0]
      policy_arn = attachment[1]
    }
  }

  group      = aws_iam_group.this[each.value.group].name
  policy_arn = each.value.policy_arn
}

resource "aws_iam_group_policy" "this" {
  for_each = {
    for name, attributes in local.groups : name => attributes if attributes.policy != ""
  }

  name  = each.value.name
  group = aws_iam_group.this[each.value.name].name

  policy = each.value.policy
}
