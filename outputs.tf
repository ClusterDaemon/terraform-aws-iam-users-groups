# vim: tabstop=2 shiftwidth=2 expandtab
output "groups" {
  description = "All IAM groups managed by this module."

  value = module.groups
}

output "users" {
  description = "All IAM users managed by this module."

  value = module.users
}
