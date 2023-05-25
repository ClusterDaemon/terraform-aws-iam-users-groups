# vim: tabstop=2 shiftwidth=2 expandtab
variable "groups" {
  description = <<EOT
    Controls the existence of groups, in addition to handling policy. Some groups are built-in, and will show via output
    along with provided groups.
  EOT

  type = list(object({
    name        = string
    path        = optional(string, "/")
    policy_arns = optional(list(string), [])
    policy      = optional(string, "")
  }))

  default = []
}

variable "users" {
  description = <<EOT
    Controls the existence of users in addition to handling access and policy. Required object attributes are name and
    pgp.
  EOT

  type = list(object({
    name           = string
    path           = optional(string, "/")
    groups         = optional(list(string), [])
    enable_mfa     = optional(bool, false)
    policy_arns    = optional(list(string), [])
    policy         = optional(string, "")

    pgp = object({
      public_key_base64 = optional(string)
      keybase_username  = optional(string)
    })

    console_password = optional(object({
      generate_password       = bool
      password_length         = optional(number, 20)
      password_reset_required = optional(bool, false)
      }), {
      generate_password = false
    })

    access_keys = optional(
      list(object({
        name   = string
        status = optional(string, "Active")
      })),
      []
    )

  }))

  validation {
    condition = alltrue([
      for name in var.users[*].name : length(regexall("^[a-zA-Z0-9\\-_,.@+=]*$", name)) > 0
    ])

    error_message = <<EOT
      Invalid value for name (must only contain alphanumeric characters, hyphens, underscores, commas,
      periods, @ symbols, plus and equals signs).
    EOT
  }

  # Check if base64 regardless of character set.
  validation {
    condition = alltrue([ for public_key_base64 in var.users[*].pgp.public_key_base64 :
      (
        public_key_base64 == null ? true :
        length(regexall("^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$", public_key_base64)) > 0
      )
    ])
    
    error_message = "Invalid value for pgp.public_key_base64 (must only contain a base64-encoded public PGP key)."
  }

  validation {
    condition = alltrue(
      [ for user in var.users : anytrue([ user.pgp.public_key_base64 != null,  user.pgp.keybase_username != null ]) ]
    )

  error_message = <<EOT
    All users must supply a public PGP key, either via pgp.public_key_base64 or pgp.keybase_username. If both are set,
    pgp.public_key_base64 will be used. This way, explicit declaration of a key disables key discovery via keybase.
  EOT
  }

  validation {
    condition = alltrue([
      for key in flatten(var.users[*].access_keys) : (
        length(regexall("^(Active|Inactive)$", key.status)) > 0
      )
    ])

    error_message = "Invalid value for status in access_keys[{}] (must contain Active or Inactive)."
  }

  default = []
}
