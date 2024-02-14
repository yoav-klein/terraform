terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }

     backend "s3" {
        bucket ="yoav-tf-backend-test"
        key = "state"
        region = "us-east-1"
    }
}

provider "aws" {}



