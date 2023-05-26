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

module "users" {
  source   = "./modules/user"
  for_each = var.users

  name             = each.key
  path             = each.value.path
  groups           = [] # Lookup for groups must go here
  enable_mfa       = each.value.enable_mfa
  policy_arns      = each.value.policy_arns
  policy           = each.value.policy
  pgp              = each.value.pgp
  console_password = each.value.console_password
  access_keys      = each.value.access_keys
}

module "groups" {
  source   = "./modules/group"
  for_each = var.groups

  name        = each.key
  path        = each.value.path
  policy_arns = each.value.policy_arns
  policy      = each.value.policy
}
