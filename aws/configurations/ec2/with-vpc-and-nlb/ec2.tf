

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
    name = "nginx-server"    
    ami = local.amis["ubuntu"]
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    default_vpc = false
    vpc_id = module.vpc.vpc_id
    subnet_ids = [ module.vpc.private_subnet_ids[0], module.vpc.public_subnet_ids[0] ]
    user_data = <<EOF
apt-get update
apt-get install nginx
EOF 
    
}
output "public_dns" {
    description = "public DNS"
    value = module.ec2.public_dns
}
