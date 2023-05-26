# vim: tabstop=2 shiftwidth=2 expandtab
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
    each.value.pgp.public_key_base64 != "" ?
    each.value.pgp.public_key_base64 :
    format("keybase:%s", each.value.pgp.keybase_username)
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
        keys[1].pgp.public_key_base64 != "" ? 
        keys[1].pgp.public_key_base64 : 
        format("keybase:%s", keys[1].pgp.keybase_username)
      )
    }
  }

  user    = aws_iam_user.this[each.value.name].name
  pgp_key = each.value.pgp_key
}
