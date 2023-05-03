

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

resource "aws_security_group" "servers" {
    name = "server-security-group"
    vpc_id = module.vpc.vpc_id
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        description = "SSH"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "TCP"
        description = "Load Balancer"
        security_groups = [ aws_security_group.load_balancer.id ]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

}

module "ec2_servers" {
    source = "../../../modules/ec2"

    name = "nginx-server"    
    ami = local.amis["ubuntu"]
    pub_key_path="${path.module}/aws.pub"
    use_default_sg = false
    security_group_ids = [aws_security_group.servers.id]
    instance_count = 2
    default_vpc = false
    vpc_id = module.vpc.vpc_id
    subnet_ids = [ module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1] ]
    user_data = <<EOF
#!/bin/bash
curl -L get.docker.com | bash
docker run --network host yoavklein3/echo:0.1
EOF    
}

module "ec2_bastion" {
    source = "../../../modules/ec2"
    name = "bastion"    
    ami = local.amis["ubuntu"]
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    default_vpc = false
    vpc_id = module.vpc.vpc_id
    subnet_ids = [ module.vpc.public_subnet_ids[0] ]
}


output "public_ec2_dns" {
    description = "public DNS"
    value = module.ec2_bastion.public_dns
}
