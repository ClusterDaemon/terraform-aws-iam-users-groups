# Terraform AWS IAM Users and Groups

![image](https://github.com/ClusterDaemon/terraform-aws-iam-users-groups/assets/14807070/c1c8e54a-f924-4e57-896b-69b02e599f10)

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
  - AWS API Access Key management
    - Activate or deactive keys
    - Rotate keys by changing their names
- Encrypted credential output
- Secure MFA device management (encrypted MFA QR code/seed output)
- Sensitive output encryption via user-supplied public PGP keys enables last-mile secret delivery
- User and group submodules can be used independently.

## Credential Decryption

Because credentials are always encypted via PGP, users must use the private key associated with the public key that was
used to encrypt secrets. Secret data output from this module is always base64 encoded, making it easy to transmit via
interpreteted data streams. Users should be able to "own" their output object, and the following instructions assume
that users have acess to their full output object.

### Obtaining a user's output object from Terraform

A user's output object can be filtered from this module's output via the user's name (the map key of the `users` input
variable). This example assumes that this module is used as a root module, or that its outputs are routed as-is within a
calling root module. The location and structure of this output object may be different depending on how the root module
is implemented. It may also be shared via a method other than Terraform's outputs (via an S3 bucket or ASM secret, for
example).

This module makes no attempt to provide anything other than a module output, which can be filtered like so:
```
terraform output -json | jq '.users.value.ClusterDaemon' > ClusterDaemon.json
```

This output is safe to share with the user directly, as non-encrypted details present in the object are not sensitive.

### Extracting credentials from a user's output object

The resulting object can contain various secret strings, all of which are base64-encoded PGP messages. Any application
capable of using a private PGP key to decrypt messages will work, though these examples use the `keybase` client
utility. Credentials are only available via a few paths, all of which are present in these examples:

Obtain a user's AWS password and decode+decrypt (MacOS, Linux):
```
jq -r '.console_password.encrypted_password_base64' ClusterDaemon.json | base64 -d | keybase pgp decrypt -o aws_password.secret
```

Obtain a user's access keys (of which there may be from none to 2), where the file name is the access key ID, and its
contents are the secret key.
```
jq '.access_keys[0].encrypted_secret_base64' ClusterDaemon.json | base64 -d | keybase pgp decrypt -o $(
  jq '.access_keys[0].id' ClusterDaemon.json
)
```

To obtain a second access key (if configured), modify the `jq` filter to `access_keys[1]`.

#### MFA Setup

MFA device registration details are encrypted and encoded, preventing man-in-the-middle MFA registration.

Obtain a user's MFA QR code or seed string:
```
jq '.virtual_mfa_device.encrypted_qr_code_png_base64' ClusterDaemon.json | base64 -d | keybase decrypt -o mfa_qr_code.png 
```

Then use your favorite image viewer to display the QR code present in `mfa_qr_code.png`. Use an MFA application on your
mobile device to scan the code. After doing so, use two consecutive tokens to register the device with AWS, completing
MFA setup:

```
aws iam enable-mfa-device --user-name ClusterDaemon --serial-number $(jq '.virtual_mfa_device.arn' ClusterDaemon.json) \
  --authentication-code1 "REPLACE THIS WITH CODE FROM MFA APPLICATION AFTER QR CODE SCAN" \
  --authentication-code2 "REPLACE THIS WITH THE VERY NEXT CODE FROM MFA APPLICATION"
```

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
