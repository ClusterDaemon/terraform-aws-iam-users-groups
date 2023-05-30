<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14, < 2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy) | resource |
| [aws_iam_group_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | AWS IAM group name | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | IAM path associated with this group. | `string` | `"/"` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Inline JSON policy for this group. | `string` | `""` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | Policies to attach to this group | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | AWS Resource Name of the created group |
| <a name="output_inline_policy"></a> [inline\_policy](#output\_inline\_policy) | JSON policy defined inline with the created group |
| <a name="output_name"></a> [name](#output\_name) | Name of the IAM group |
| <a name="output_path"></a> [path](#output\_path) | Path applied to IAM resources |
| <a name="output_policy_arns"></a> [policy\_arns](#output\_policy\_arns) | Policies attached to the created group |
| <a name="output_unique_id"></a> [unique\_id](#output\_unique\_id) | Unique identifier associated with this group |
<!-- END_TF_DOCS -->