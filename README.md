# Terraform AWS IAM Users and Groups

A Terraform resource module that manages IAM users and groups for a single AWS account. This is not dependent on SSO or SAML, and is primarily operated using two lists - one for users, and one for groups. The module provides similar outputs that are sorted by user and group name for easy reference. The outputs of this module are encrypted, and are safe to provide to users directly.

This module handles various resources related to user access, and provides that access via encrypted output fields. Encryption is accomplished using PGP, and users are required to provide a public PGP key in order to generate passwords and API keys. Public keys may be provided as base64 encoded strings, or as a keybase user ID: `keybase:<username>`.

## Features

- Manage many users and groups within a single module call
- AWS login (console) password generation
  - Encrypted secret delivery via output
- AWS API access via Access Keys management
  - Define a maximum of two keys per user
  - Activate or deactive keys
  - Rotate keys by changing their names
  - Encrypted secret delivery via output
- MFA device management per user
  - QR code and URL provided via output
- Strict input variable schema and validation checking/feedback

## Roadmap

- Better MFA PNG output handling
- Strict/opnionated password, key, and MFA policies

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.65 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy) | resource |
| [aws_iam_group_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_group_membership) | resource |
| [aws_iam_user_login_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile) | resource |
| [aws_iam_user_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_iam_user_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_virtual_mfa_device.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_virtual_mfa_device) | resource |
| [external_external.encrypt_and_encode_mfa](https://registry.terraform.io/providers/hashicorp/external/2.3.1/docs/data-sources/external) | data source |
| [http_http.keybase](https://registry.terraform.io/providers/hashicorp/http/3.3.0/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_groups"></a> [groups](#input\_groups) | Controls the existence of groups, in addition to handling policy. Map keys are group names unless overidden by<br>    setting the name attribute. | <pre>map(object({<br>    name        = optional(string, "")<br>    path        = optional(string, "/")<br>    policy_arns = optional(list(string), [])<br>    policy      = optional(string, "")<br>  }))</pre> | `{}` | no |
| <a name="input_users"></a> [users](#input\_users) | Controls the existence of users in addition to handling access and policy. Map keys are usernames unless overridden<br>    by setting the name attribute. | <pre>map(object({<br>    name           = optional(string, "")<br>    path           = optional(string, "/")<br>    groups         = optional(list(string), [])<br>    enable_mfa     = optional(bool, false)<br>    policy_arns    = optional(list(string), [])<br>    policy         = optional(string, "")<br><br>    pgp = object({<br>      public_key_base64 = optional(string, "")<br>      keybase_username  = optional(string, "")<br>    })<br><br>    console_password = optional(object({<br>      generate_password       = bool<br>      password_length         = optional(number, 20)<br>      password_reset_required = optional(bool, false)<br>      }), {<br>      generate_password = false<br>    })<br><br>    access_keys = optional(<br>      list(object({<br>        name   = string<br>        status = optional(string, "Active")<br>      })),<br>      []<br>    )<br><br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_groups"></a> [groups](#output\_groups) | All IAM groups managed by this module. |
| <a name="output_users"></a> [users](#output\_users) | All IAM users managed by this module. |
<!-- END_TF_DOCS -->

## Generating Documentation

Just execute `$ terraform-docs markdown --output-mode inject --output-file README.md ./`.
