terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
  shared_credentials_file = "../.aws/credentials"
  profile                 = "sandbox"
}

resource "aws_config_config_rule" "restricted_ssh" {
  name        = "restricted-ssh"
  description = "Checks whether security groups that are in use disallow unrestricted incoming SSH traffic."

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
    }
}