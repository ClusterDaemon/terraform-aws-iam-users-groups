output "groups" {
  description = "All IAM groups managed by this module."

  value = [for name, attributes in local.groups : {
    name      = aws_iam_group.this[name].name
    path      = aws_iam_group.this[name].path
    arn       = aws_iam_group.this[name].arn
    unique_id = aws_iam_group.this[name].unique_id

    policy_arns = concat(
      [for arn in attributes.policy_arns : aws_iam_group_policy_attachment.this[format("%s-%s", name, arn)].name],
      attributes.policy != "" ? [aws_iam_group_policy.this[name].arn] : tolist([])
    )
  }]

}

output "users" {
  description = "All IAM users managed by this module."

  value = [for name, attributes in local.users : {
    name      = aws_iam_user.this[name].name
    path      = aws_iam_user.this[name].path
    arn       = aws_iam_user.this[name].arn
    unique_id = aws_iam_user.this[name].unique_id
    groups    = attributes.groups != tolist([]) ? aws_iam_user_group_membership.this[name].name : null

    policy_arns = concat(
      [for arn in attributes.policy_arns : aws_iam_group_policy_attachment.this[format("%s-%s", name, arn)].name],
      attributes.policy != "" ? [aws_iam_group_policy.this[name].arn] : tolist([])
    )

    console_password = (
      attributes.console_password.generate_password ?
      {
        encrypted_password  = aws_iam_user_login_profile.this[name].encrypted_password
        pgp_key_fingerprint = aws_iam_user_login_profile.this[name].key_fingerprint
      } :
      null
    )

    access_keys = [
      for key in attributes.access_keys : {
        access_key_id                  = aws_iam_access_key.this[name].id
        encrypted_secret_access_key    = aws_iam_access_key.this[name].encrypted_secret
        encrypted_ses_smtp_password_v4 = aws_iam_access_key.this[name].encrypted_ses_smtp_password_v4
        pgp_key_fingerprint            = aws_iam_access_key.this[name].key_fingerprint
      }
    ]

    virtual_mfa_device = (
      attributes.enable_mfa ?
      {
        arn                 = aws_iam_virtual_mfa_device.this[name].arn
        qr_code_png         = aws_iam_virtual_mfa_device.this[name].qr_code_png
        base_32_string_seed = aws_iam_virtual_mfa_device.this[name].base_32_string_seed
      } :
      null
    )

  }]

}
