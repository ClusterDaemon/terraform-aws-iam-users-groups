# vim: tabstop=2 shiftwidth=2 expandtab
output "groups" {
  description = "All IAM groups managed by this module."

  value = { for name, attributes in local.groups : name => {
    name      = aws_iam_group.this[name].name
    path      = aws_iam_group.this[name].path
    arn       = aws_iam_group.this[name].arn
    unique_id = aws_iam_group.this[name].unique_id

    policy_arns = [
      for arn in attributes.policy_arns : aws_iam_group_policy_attachment.this[format("%s-%s", name, arn)].group
    ]

    inline_policy = attributes.policy != "" ? aws_iam_group_policy.this[name].policy : null
  }}

}

output "users" {
  description = "All IAM users managed by this module."

  value = { for name, attributes in local.users : name => {
    name          = aws_iam_user.this[name].name
    path          = aws_iam_user.this[name].path
    arn           = aws_iam_user.this[name].arn
    unique_id     = aws_iam_user.this[name].unique_id
    groups        = attributes.groups != tolist([]) ? aws_iam_user_group_membership.this[name].groups : null

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
        access_key_id               = aws_iam_access_key.this[format("%s-%s", name, key.name)].id
        encrypted_secret_access_key = aws_iam_access_key.this[format("%s-%s", name, key.name)].encrypted_secret
        pgp_key_fingerprint         = aws_iam_access_key.this[format("%s-%s", name, key.name)].key_fingerprint

        encrypted_ses_smtp_password_v4 = (
          aws_iam_access_key.this[format("%s-%s", name, key.name)].encrypted_ses_smtp_password_v4
        )

      }
    ]

    virtual_mfa_device = (
      attributes.enable_mfa ?
      {
        arn = aws_iam_virtual_mfa_device.this[name].arn

        qr_code_png_encrypted_base64 = (
          data.external.encrypt_and_encode_mfa[format("%s-qr_code_png", name)].result.encrypted_base64
        )

        base_32_string_seed_encrypted_base64 = (
          data.external.encrypt_and_encode_mfa[format("%s-base_32_string_seed", name)].result.encrypted_base64
        )

      } :
      null
    )

    attached_policy_arns = [
      for arn in attributes.policy_arns : aws_iam_user_policy_attachment.this[format("%s-%s", name, arn)].policy_arn
    ]

    inline_policy = attributes.policy != "" ? aws_iam_user_policy.this[name].policy : null
  }}

}
