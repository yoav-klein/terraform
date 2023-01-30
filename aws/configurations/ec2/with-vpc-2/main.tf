
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

module "vpc" {
    source = "../../../modules/vpc"
    name = "my_vpc"
    cidr = "10.0.0.0/16"
    public_subnets = [{ 
        az = "us-east-1b"
        cidr = "10.0.1.0/24"
    }]
    private_subnets = [{
        az = "us-east-1a",
        cidr = "10.0.2.0/24"
    }]
}

module "pvt-instance" {
    source = "../../../modules/ec2"
    instance_count = 3
    
    ami = "ami-00874d747dde814fa"
    name = "my-instance"
    pub_key_path = "${path.module}/aws.pub"
    subnet_ids = module.vpc.public_subnet_ids
    default_vpc = false
    vpc_id = module.vpc.vpc_id
}
