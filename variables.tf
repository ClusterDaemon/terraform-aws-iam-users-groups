# vim: tabstop=2 shiftwidth=2 expandtab
variable "groups" {
  description = "Controls the existence of groups, in addition to handling policy. Map keys are group names."

  type = map(object({
    path        = optional(string, "/")
    policy_arns = optional(list(string), [])
    policy      = optional(string, "")
  }))

  default = {}
}

variable "users" {
  description = "Controls the existence of users in addition to handling access and policy. Map keys are usernames."

  type = map(object({
    path           = optional(string, "/")
    groups         = optional(list(string), [])
    mfa_enabled    = optional(bool, true)
    policy_arns    = optional(list(string), [])
    policy         = optional(string, "")

    pgp = object({
      public_key_base64 = optional(string, "")
      keybase_username  = optional(string, "")
    })

    console_password = optional(
      object({
        generate_password       = optional(bool, true)
        password_length         = optional(number, 20)
        password_reset_required = optional(bool, false)
      }),
      { generate_password = true }
    )

    access_keys = optional(
      list(object({
        name   = string
        status = optional(string, "Active")
      })),
      []
    )

  }))

  default = {}

  validation {
    condition = alltrue([ for name in keys(var.users)[*] : 
      anytrue([ length(regexall("^[a-zA-Z0-9\\-_,.@+=]*$", name)) > 0, name == "" ])
    ])

    error_message = <<EOT
      Invalid value for name (must only contain alphanumeric characters, hyphens, underscores, commas,
      periods, @ symbols, plus and equals signs).
    EOT
  }
}
