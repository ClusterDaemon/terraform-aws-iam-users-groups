# vim: tabstop=2 shiftwidth=2 expandtab
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
