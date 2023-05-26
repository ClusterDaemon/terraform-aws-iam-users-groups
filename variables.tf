# vim: tabstop=2 shiftwidth=2 expandtab
variable "groups" {
  description = <<EOT
    Controls the existence of groups, in addition to handling policy. Map keys are group names unless overidden by
    setting the name attribute.
  EOT

  type = map(object({
    name        = optional(string, "")
    path        = optional(string, "/")
    policy_arns = optional(list(string), [])
    policy      = optional(string, "")
  }))

  default = {}
}

variable "users" {
  description = <<EOT
    Controls the existence of users in addition to handling access and policy. Map keys are usernames unless overridden
    by setting the name attribute.
  EOT

  type = map(object({
    name           = optional(string, "")
    path           = optional(string, "/")
    groups         = optional(list(string), [])
    enable_mfa     = optional(bool, false)
    policy_arns    = optional(list(string), [])
    policy         = optional(string, "")

    pgp = object({
      public_key_base64 = optional(string, "")
      keybase_username  = optional(string, "")
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
    condition = alltrue([ for name in values(var.users)[*].name : 
      anytrue([ length(regexall("^[a-zA-Z0-9\\-_,.@+=]*$", name)) > 0, name == "" ])
    ])

    error_message = <<EOT
      Invalid value for name (must only contain alphanumeric characters, hyphens, underscores, commas,
      periods, @ symbols, plus and equals signs).
    EOT
  }

  # Check if base64 regardless of character set.
  validation {
    condition = alltrue([ for public_key_base64 in values(var.users)[*].pgp.public_key_base64 :
      (
        public_key_base64 == "" ? true :
        length(regexall("^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$", public_key_base64)) > 0
      )
    ])
    
    error_message = "Invalid value for pgp.public_key_base64 (must only contain a base64-encoded public PGP key)."
  }

  validation {
    condition = alltrue([ for user in values(var.users) :
      anytrue([ user.pgp.public_key_base64 != "",  user.pgp.keybase_username != "" ])
    ])

  error_message = <<EOT
    All users must supply a public PGP key, either via pgp.public_key_base64 or pgp.keybase_username. If both are set,
    pgp.public_key_base64 will be used. This way, explicit declaration of a key disables key discovery via keybase.
  EOT
  }

  validation {
    condition = alltrue([ for key in flatten(values(var.users)[*].access_keys) :
      length(regexall("^(Active|Inactive)$", key.status)) > 0
    ])

    error_message = "Invalid value for status in access_keys[{}] (must contain Active or Inactive)."
  }

  default = {}
}
