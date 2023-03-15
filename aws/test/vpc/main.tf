
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
}
module "vpc" {
  source   = "../../modules/vpc"
  name = "my_test_vpc"
  cidr     = "10.0.0.0/16"
  public_subnets = [{
    az   = "us-east-1b"
    cidr = "10.0.1.0/24"
    },
    {
      az   = "us-east-1c"
      cidr = "10.0.2.0/24"
  }]
  private_subnets = [{
    az   = "us-east-1a",
    cidr = "10.0.3.0/24"
  }]
}
