

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}

locals {
    amis = {
        ubuntu = "ami-0f1bae6c3bedcc3b5"
    }
}

module "ec2" {
    source = "../../../modules/ec2"
    name = "my-server"    
    ami = local.amis["ubuntu"]
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    default_vpc = true
    
}

output "public_dns" {
    description = "public DNS"
    value = module.ec2.public_dns
}
