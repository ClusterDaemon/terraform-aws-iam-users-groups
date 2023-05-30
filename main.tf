# vim: tabstop=2 shiftwidth=2 expandtab
terraform {
  required_version = "~>1.4"
}

module "users" {
  source   = "./modules/user"
  for_each = var.users

  name             = each.key
  path             = each.value.path
  mfa_enabled      = each.value.mfa_enabled
  policy_arns      = each.value.policy_arns
  policy           = each.value.policy
  pgp              = each.value.pgp
  console_password = each.value.console_password
  access_keys      = each.value.access_keys

  groups = [ for group in each.value.groups : contains(keys(var.groups), group) ? module.groups[group].name : group ]
}

module "groups" {
  source   = "./modules/group"
  for_each = var.groups

  name        = each.key
  path        = each.value.path
  policy_arns = each.value.policy_arns
  policy      = each.value.policy
}
