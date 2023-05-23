# vim: tabstop=2 shiftwidth=2 expandtab
terraform {
  required_providers {
    pgp = {
      source = "ekristen/pgp"
      version = "0.2.4"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

provider "pgp" {}

resource "pgp_key" "joe" {
  name    = "Joe Dirt"
  email   = "Joe@dirt.tld"
  comment = "Example key!"
}

module "users_groups" {
  source = "../"

  users = [

    {
      name           = "Joe-Dirt"
      pgp_public_key = pgp_key.joe.public_key_base64

      console_password = {
        generate_password = true
      }

      access_keys = [
        { name = "able" },
        {
          name = "baker"
          status = "Inactive"
        }
      ]
      
      enable_mfa = true

      groups = ["Administrators"]
    },

    {
      name           = "ClusterDaemon"
      pgp_public_key = "keybase:clusterdaemon"
      enable_mfa  = true

      policy_arns = [ "arn:aws:iam::aws:policy/AdministratorAccess" ]

      access_keys = [{ name = "thing1" }]

      policy = jsonencode(
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "LameExample",
              "Effect": "Allow",
              "Action": [
                "s3:ListBuckets"
              ],
              "Resource": "*"
            }
          ]
        }
      )

    },

    {
      name = "NoAccess"
      groups = [ "Nobodies" ]
      pgp_public_key = "keybase:clusterdaemon"
    }

  ]

  groups = [
    
    {
      name = "Administrators"
      policy_arns = [ "arn:aws:iam::aws:policy/AdministratorAccess" ]
    },

    {
      name = "Nobodies"
      
      policy = jsonencode(
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Sid": "LameExample",
              "Effect": "Allow",
              "Action": [
                "s3:ListBuckets"
              ],
              "Resource": "*"
            }
          ]
        }
      )
        
    },

  ]
}

module "only_users" {
  source = "../"

  users = [
    {
      name = "OnlyUsers"
      pgp_public_key = pgp_key.joe.public_key_base64
    }
  ]
}

module "only_groups" {
  source = "../"

  groups = [
    {
      name = "OnlyGroups"
    }
  ]
}

# Feels like I'm wearing nothing at all!
module "nothing_at_all" { # Nothing at all!
  source = "../"
}

output "users" {
  value = module.users_groups.users
}

output "groups" {
  value = module.users_groups.groups
}

output "only_users" {
  value = module.only_users.users
}

output "only_groups" {
  value = module.only_groups.groups
}

output "nothing_at_all" {
  value = module.nothing_at_all
}
