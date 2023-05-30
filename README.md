# Terraform AWS IAM Users and Groups

A Terraform resource module that manages IAM users and groups for a single AWS account, in addition to secure credential
generation and management.

This module (and its series of independently deployable submodules) aims to provide a method of managing the full
lifecycle of identities in AWS via user self-service.

The outputs of this module require encryption via public PGP keys in order to manage credentials. Public keys may be
provided as a keybase username, or a base64 encoded key. A valid PGP key is required for user creation.

## Features

- Manage users and groups in addition to handling credentials generation and encryption
  - AWS login (console) passwords
    - Configurable password requirements
  - AWS API Access Keys
    - Activate or deactive keys
    - Rotate keys by changing their names
- Encrypted credential output
- Secure MFA device management (encrypted MFA QR code/seed output)
- Sensitive output encryption via user-supplied public PGP keys enables last-mile secret delivery
- User and group submodules can be used independently

## Roadmap

- Strict/opnionated password, key, and MFA policies
  - Evaluation of an MFA submodule

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_groups"></a> [groups](#module\_groups) | ./modules/group | n/a |
| <a name="module_users"></a> [users](#module\_users) | ./modules/user | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_groups"></a> [groups](#input\_groups) | Controls the existence of groups, in addition to handling policy. Map keys are group names. | <pre>map(object({<br>    path        = optional(string, "/")<br>    policy_arns = optional(list(string), [])<br>    policy      = optional(string, "")<br>  }))</pre> | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | Controls the existence of users in addition to handling access and policy. Map keys are usernames. | <pre>map(object({<br>    path           = optional(string, "/")<br>    groups         = optional(list(string), [])<br>    mfa_enabled    = optional(bool, true)<br>    policy_arns    = optional(list(string), [])<br>    policy         = optional(string, "")<br><br>    pgp = object({<br>      public_key_base64 = optional(string, "")<br>      keybase_username  = optional(string, "")<br>    })<br><br>    console_password = optional(<br>      object({<br>        generate_password       = optional(bool, true)<br>        password_length         = optional(number, 20)<br>        password_reset_required = optional(bool, false)<br>      }),<br>      { generate_password = true }<br>    )<br><br>    access_keys = optional(<br>      list(object({<br>        name   = string<br>        status = optional(string, "Active")<br>      })),<br>      []<br>    )<br><br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_groups"></a> [groups](#output\_groups) | All IAM groups managed by this module. |
| <a name="output_users"></a> [users](#output\_users) | All IAM users managed by this module. |
<!-- END_TF_DOCS -->

## Generating Documentation

Just execute `$ terraform-docs markdown --output-mode inject --output-file README.md ./`.
