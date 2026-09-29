
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

     tls = {
      source = "hashicorp/tls"
    }

    local = {
      source = "hashicorp/local"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
