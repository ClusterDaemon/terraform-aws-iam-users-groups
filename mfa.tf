# vim: tabstop=2 shiftwidth=2 expandtab
locals {
  mfa_users = {
    for name, attributes in local.users : name => attributes if attributes.enable_mfa
  }
  mfa_objects = {
    for s3_object in setproduct(keys(local.mfa_users), [ "qr_code_png", "base_32_string_seed" ]) :
      format("%s-%s", s3_object[0], s3_object[1]) => merge(
        local.mfa_users[s3_object[0]],
        { mfa_attribute_name = s3_object[1] }
      )
  }
}

resource "aws_iam_virtual_mfa_device" "this" {
  for_each = local.mfa_users

  virtual_mfa_device_name = each.value.name
  path                    = each.value.path
}

data "http" "keybase" {
  for_each = {
    for name, attributes in local.mfa_users : name => attributes.pgp
    if alltrue([ attributes.pgp.keybase_username != "", attributes.pgp.public_key_base64 == "" ])
  }

  url = format(
    "https://keybase.io/_/api/1.0/user/lookup.json?usernames=%s",
    each.value.keybase_username
  )
}

data "external" "encrypt_and_encode_mfa" {
  for_each = {
    for name, attributes in local.mfa_objects : name => merge(attributes, {

      pgp_public_key = (
        attributes.pgp.public_key_base64 != "" ?
        attributes.pgp.public_key_base64 :
        base64encode(jsondecode(data.http.keybase[attributes.name].body).them[0].public_keys.primary.bundle)
      )

    })
  }

  program = [
    format("%s/scripts/encrypt-and-encode.sh", path.module),
    each.value.pgp_public_key,
    base64encode(aws_iam_virtual_mfa_device.this[each.value.name][each.value.mfa_attribute_name]),
  ]

}
