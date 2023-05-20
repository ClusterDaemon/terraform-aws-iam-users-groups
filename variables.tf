variable "groups" {
  description = <<EOT
    Controls the existence of groups, in addition to handling policy. Some groups are built-in, and will show via output
    along with provided groups.
  EOT

  type = list(object({
    name        = string
    path        = optional(string, "/")
    policy_arns = optional(list(string), [])
    policy      = optional(string)
  }))

  default = []
}

variable "users" {
  description = <<EOT
    Controls the existence of users in addition to handling access and policy. Some users are built-in, and will show
    via output along with provided users.
  EOT

  type = list(object({
    name   = string
    path   = optional(string, "/")
    groups = optional(list(string), [])

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
    })))

    enable_mfa               = optional(bool, false)
    policy_arns              = optional(list(string), [])
    policy                   = optional(string)
    pgp_public_key           = string
  }))

  validation {
    condition = alltrue([
      for public_key in var.users[*].pgp_public_key : anytrue([
        can(base64decode(public_key)),
        regexall("^keybase\\:.*", public_key) > 0
      ])
    ])
    error_message = <<EOT
      Public PGP key must either be a base64 encoded key or a keybase identity that has a PGP key (keybase:<username>).
    EOT
  }

  validation {
    condition = alltrue([ 
      for key_status in flatten(var.users[*].access_keys[*].status) : regexall("^(Active|Inactive)$", key_status) > 0
    ])

    error_message = "Access keys can have a status of Active or Inactive, which is case sensitive."
  }

  default = []
}
