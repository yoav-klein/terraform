
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

provider "aws" {}

resource "aws_kms_key" "this" {
  description              = "SigningDocker"
  key_usage = "SIGN_VERIFY"
  customer_master_key_spec = "RSA_2048"
  deletion_window_in_days  = 10
}

resource "aws_kms_alias" "this" {
  name          = "alias/my-rsa-key"
  target_key_id = aws_kms_key.this.key_id
}
