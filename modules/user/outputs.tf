# vim: tabstop=2 shiftwidth=2 expandtab
output "name" {
  description = "AWS IAM username"
  value       = aws_iam_user.this.name
}

output "path" {
  description = "Path in IAM. Does not contribute to uniqueness. Defined for all IAM resources."
  value       = aws_iam_user.this.path
}

output "arn" {
  description = "Amazon Resource Name for the IAM user."
  value       = aws_iam_user.this.arn
}

output "unique_id" {
  description = "Unique identifier for the IAM user."
  value       = aws_iam_user.this.unique_id
}

output "groups" {
  description = "Groups the IAM user is a member of."
  value       = aws_iam_user_group_membership.this.groups
}

output "console_password" {
  description = "Encrypted password for AWS console and services access."

  value = {
    encrypted_password  = join("", aws_iam_user_login_profile.this[*].encrypted_password)
    pgp_key_fingerprint = join("", aws_iam_user_login_profile.this[*].key_fingerprint)
  }
}

output "access_keys" {
  description = "AWS API access keys, of whih there can be no more than two regardless of state."

  value = [ for key in var.access_keys : {
    name                           = key.name
    id                             = aws_iam_access_key.this[key.name].id
    status                         = aws_iam_access_key.this[key.name].status
    encrypted_secret               = aws_iam_access_key.this[key.name].encrypted_secret
    encrypted_ses_smtp_password_v4 = aws_iam_access_key.this[key.name].encrypted_ses_smtp_password_v4
    pgp_key_fingerprint            = aws_iam_access_key.this[key.name].key_fingerprint
  }]
}

output "virtual_mfa_device" {
  description = "Registration data for a MFA device. Used to complete the setup process asychronously."

  value = (
    var.mfa_enabled ?
    {
      arn = aws_iam_virtual_mfa_device.this[0].arn

      encrypted_qr_code_png_base64 = (
        data.external.encrypt_and_encode_mfa["qr_code_png"].result.encrypted_base64
      )

      encrypted_base_32_string_seed_base64 = (
        data.external.encrypt_and_encode_mfa["base_32_string_seed"].result.encrypted_base64
      )
    } :
    {}
  )
}

output "attached_policy_arns" {
  description = "IAM policies attached to the user"
  value       = [ for arn in var.policy_arns : aws_iam_user_policy_attachment.this[arn].policy_arn ]
}

output "inline_policy" {
  description = "JSON IAM policy associated directly with the user."
  value       = aws_iam_user_policy.this[*].policy
}
