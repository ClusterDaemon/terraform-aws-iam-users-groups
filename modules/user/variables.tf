# vim: tabstop=2 shiftwidth=2 expandtab
variable "name" {
  description = "AWS IAM username"
  type        = string

  validation {
    condition = length(regexall("^[a-zA-Z0-9\\-_,.@+=]*$", var.name)) > 0

    error_message = <<-EOT
      Invalid value for name (must only contain alphanumeric characters, hyphens, underscores, commas, periods, @
      symbols, plus and equals signs).
    EOT

  }
}

variable "path" {
  description = "Path in IAM. Does not contribute to uniqueness."
  type        = string
  default     = "/"
}

variable "groups" {
  description = "Groups the user is a member of"
  type        = list(string)
  default     = []
}

variable "mfa_enabled" {
  description = <<-EOT
    Creates an mfa device with the same name as the user with encrypted enrollment output. Refer to USING
    MFA for instructions on decoding and decryption as well as device registration.
  EOT

  type    = bool
  default = true
}

variable "policy_arns" {
  description = <<-EOT
    Existing policies to attach to this user. Avoid applying policies that grant or deny permissions to
    users when a group or role policy could be used instead.
  EOT

  type    = list(string)
  default = []
}

variable "policy" {
  description = <<-EOT
    JSON policy to apply inline with this user. Avoid applying policies that grant or deny permissions to
    users when a group or role policy could be used instead.
  EOT

  type    = string
  default = ""

  validation {
    condition     = var.policy == "" ? true : can(jsondecode(var.policy))
    error_message = "Policy must be in JSON format."
  }
}

variable "pgp" {
  description = "A PGP public key, specified as a keybase username or a base64-encoded public key."

  type = object({
    public_key_base64 = optional(string, "")
    keybase_username  = optional(string, "")
  })

  validation {
    condition = (
      var.pgp.public_key_base64 == "" ? true :
      length(regexall("^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$", var.pgp.public_key_base64)) > 0
    )

    error_message = "Invalid value for pgp.public_key_base64 (must only contain a base64-encoded public PGP key)."
  }

  validation {
    condition = anytrue([ var.pgp.public_key_base64 != "",  var.pgp.keybase_username != "" ])

    error_message = <<EOT
      Users must supply a public PGP key, either via pgp.public_key_base64 or pgp.keybase_username. If both are set,
      pgp.public_key_base64 will be used. This way, explicit declaration of a key disables key discovery via keybase.
    EOT
  } 
}

variable "console_password" {
  description = "AWS login password, usable via the web console."
  
  type        = object({
    generate_password       = bool
    password_length         = optional(number, 20)
    password_reset_required = optional(bool, false)
  })

  default = { generate_password = true }
}

variable "access_keys" {
  description = "AWS API access keys. Two keys (list elements) maximum. Key state may be Active or Inactive."

  type = list(object({
    name   = string
    status = optional(string, "Active")
  }))

  default = []

  validation {
    condition = (
      0 == length(var.access_keys) ? true : (
        length(var.access_keys) <= 2 ?
        length(regexall("^(Active|Inactive)$", var.access_keys[0].status)) > 0 :
        true
      )
    )

    error_message = "Invalid value for status in access_keys[0]. Must be one of Active or Inactive."
  }

  validation {
    condition = (
      length(var.access_keys) == 2 ?
      length(regexall("^(Active|Inactive)$", var.access_keys[1].status)) > 0 :
      true
    )

    error_message = "Invalid value for status in access_keys[1]. Must be one of Active or Inactive."
  }

  validation {
    condition     = length(var.access_keys) <= 2
    error_message = "There can be no more than two access keys."
  }
}

variable "tags" {
  description = "AWS tags which apply to all resources in this module."
  type        = map(string)
  default     = {}
}
