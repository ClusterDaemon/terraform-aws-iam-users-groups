# vim: tabstop=2 shiftwidth=2 expandtab
resource "aws_iam_group" "this" {
  for_each = local.groups

  name = each.value.name
  path = each.value.path
}

resource "aws_iam_user_group_membership" "this" {
  for_each = {
    for name, attributes in local.users : name => attributes if attributes.groups == tolist([])
  }

  user = aws_iam_user.this[each.key].name

  # If the requested group has been defined in this module, create an implicit dependency.
  groups = [
    for group in each.value.groups : (
      contains(keys(aws_iam_group.this), group) ?
      aws_iam_group.this[group].name :
      group
    )
  ]

}

resource "aws_iam_group_policy_attachment" "this" {
  for_each = {
    for attachment in [
      for group in local.groups : setproduct([group.name], group.policy_arns)
      ] : format("%s-%s", attachment[0], attachment[1]) => {
      group      = attachment[0]
      policy_arn = attachment[1]
    }
  }

  group      = each.value.group
  policy_arn = each.value.policy_arn
}

resource "aws_iam_group_policy" "this" {
  for_each = { for name, attributes in local.groups : name => attributes if contains(attributes, "policy") }

  name  = each.value.name
  group = each.value.name

  policy = jsonencode(each.value.policy)
}
