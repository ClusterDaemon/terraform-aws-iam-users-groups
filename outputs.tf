# vim: tabstop=2 shiftwidth=2 expandtab
output "groups" {
  description = "All IAM groups managed by this module. For output structure details, refer to the group submodule."

  value = module.groups
}

output "users" {
  description = "All IAM users managed by this module. For output structure details, refer to the user submodule."

  value = module.users
}
