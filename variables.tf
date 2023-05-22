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
    Controls the existence of users in addition to handling access and policy. Some users are built-in, and will show
    via output along with provided users.
  EOT

  type = list(object({
    name           = string
    pgp_public_key = string
    path           = optional(string, "/")
    groups         = optional(list(string), [])
    enable_mfa     = optional(bool, false)
    policy_arns    = optional(list(string), [])
    policy         = optional(string, "")

    console_password = optional(object({
      generate_password       = bool
      password_length         = optional(number, 20)
      password_reset_required = optional(bool, false)
      }), {
      generate_password = false
    })

    access_keys = optional(list(object({
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

  validation {
    condition = alltrue([
      for public_key in var.users[*].pgp_public_key : anytrue([
        length(regexall("^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$", public_key)) > 0,
        length(regexall("^keybase:[a-z0-9]+$", public_key)) > 0
      ])
    ])
    error_message = <<EOT
      Public PGP key must either be a base64 encoded key or a keybase identity that has a PGP key (keybase:<username>).
    EOT
  }

  validation {
    condition = alltrue([
      for key in flatten(var.users[*].access_keys) : (
        length(regexall("^(Active|Inactive)$", key.status)) > 0
      )
    ])

    error_message = "Access keys can have a status of Active or Inactive, which is case sensitive."
  }

  default = []
}
