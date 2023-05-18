

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

provider "aws" {}

locals {
    buckets = {
        first_yoav = "first-bucket-yoav"
        second_yoav = "second-bucket-yoav"
    }
}

resource "aws_s3_bucket" "bucket" {
    for_each = {
        for k, v in local.buckets : k => v
    }

    bucket = each.value
}
