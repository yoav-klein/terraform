
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}


####################################################################
resource "aws_iam_user" "elastic_user" {
    name = "elastic_user"
    tags = {
        group = "dev"
    }
}

resource "aws_iam_access_key" "elastic_user" {
    user = aws_iam_user.elastic_user.name
}

output "elastic_user_key_id" {
    value = aws_iam_access_key.elastic_user.id
    sensitive = true
}

output "elastic_user_secret" {
    value = aws_iam_access_key.elastic_user.secret
    sensitive = true
}


####################################################################
resource "aws_iam_user" "elastic_power" {
    name = "elastic_power"
    tags = {
        group = "devops"
    }
}

resource "aws_iam_access_key" "elastic_power" {
    user = aws_iam_user.elastic_power.name
}

output "elastic_power_key_id" {
    value = aws_iam_access_key.elastic_power.id
    sensitive = true
}

output "elastic_power_secret" {
    value = aws_iam_access_key.elastic_power.secret
    sensitive = true
}

####################################################################
resource "aws_iam_user" "elastic_admin" {
    name = "elastic_admin"
    tags = {
        group = "devops"
    }
}

resource "aws_iam_access_key" "elastic_admin" {
    user = aws_iam_user.elastic_admin.name
}

output "elastic_admin_key_id" {
    value = aws_iam_access_key.elastic_admin.id
    sensitive = true
}

output "elastic_admin_secret" {
    value = aws_iam_access_key.elastic_admin.secret
    sensitive = true
}

