<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.65 |
| <a name="requirement_external"></a> [external](#requirement\_external) | 2.3.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 3.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.0.1 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.1 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
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
| <a name="input_access_keys"></a> [access\_keys](#input\_access\_keys) | AWS API access keys. Two keys (list elements) maximum. Key state may be Active or Inactive. | <pre>list(object({<br>    name   = string<br>    status = optional(string, "Active")<br>  }))</pre> | `[]` | no |
| <a name="input_console_password"></a> [console\_password](#input\_console\_password) | AWS login password, usable via the web console. | <pre>object({<br>    generate_password       = bool<br>    password_length         = optional(number, 20)<br>    password_reset_required = optional(bool, false)<br>  })</pre> | <pre>{<br>  "generate_password": true<br>}</pre> | no |
| <a name="input_groups"></a> [groups](#input\_groups) | Groups the user is a member of | `list(string)` | `[]` | no |
| <a name="input_mfa_enabled"></a> [mfa\_enabled](#input\_mfa\_enabled) | Creates an mfa device with the same name as the user with encrypted enrollment output. Refer to USING<br>MFA for instructions on decoding and decryption as well as device registration. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | AWS IAM username | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Path in IAM. Does not contribute to uniqueness. | `string` | `"/"` | no |
| <a name="input_pgp"></a> [pgp](#input\_pgp) | A PGP public key, specified as a keybase username or a base64-encoded public key. | <pre>object({<br>    public_key_base64 = optional(string, "")<br>    keybase_username  = optional(string, "")<br>  })</pre> | n/a | yes |
| <a name="input_policy"></a> [policy](#input\_policy) | JSON policy to apply inline with this user. Avoid applying policies that grant or deny permissions to<br>users when a group or role policy could be used instead. | `string` | `""` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | Existing policies to attach to this user. Avoid applying policies that grant or deny permissions to<br>users when a group or role policy could be used instead. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | AWS tags which apply to all resources in this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_keys"></a> [access\_keys](#output\_access\_keys) | AWS API access keys, of whih there can be no more than two regardless of state. |
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name for the IAM user. |
| <a name="output_attached_policy_arns"></a> [attached\_policy\_arns](#output\_attached\_policy\_arns) | IAM policies attached to the user |
| <a name="output_console_password"></a> [console\_password](#output\_console\_password) | Encrypted password for AWS console and services access. |
| <a name="output_groups"></a> [groups](#output\_groups) | Groups the IAM user is a member of. |
| <a name="output_inline_policy"></a> [inline\_policy](#output\_inline\_policy) | JSON IAM policy associated directly with the user. |
| <a name="output_name"></a> [name](#output\_name) | AWS IAM username |
| <a name="output_path"></a> [path](#output\_path) | Path in IAM. Does not contribute to uniqueness. Defined for all IAM resources. |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | Unique identifier for the IAM user. |
| <a name="output_virtual_mfa_device"></a> [virtual\_mfa\_device](#output\_virtual\_mfa\_device) | Registration data for a MFA device. Used to complete the setup process asychronously. |
<!-- END_TF_DOCS -->