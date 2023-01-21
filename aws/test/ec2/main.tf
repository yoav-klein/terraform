

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}


######################################################
#
#   Use default VPC
#
######################################################
/*
module "my-instance" {
    name = "my-instance"
    source = "../../modules/ec2"
    instance_type = "t2.micro"
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    default_vpc = true
}
*/
######################################################
#
#   Use non-default VPC
#
######################################################

/*
module "vpc" {
    name = "my-vpc"
    source = "../../modules/vpc"
    cidr = "10.0.0.0/16"
    public_subnets = [ { cidr = "10.0.1.0/24", az = "us-east-1a" } ]
    private_subnets = [ { cidr = "10.0.2.0/24", az = "us-east-1b" } ]
    auto_assign_public_ip = true
}

module "pub-instance" {
    name = "pub-instance"
    source = "../../modules/ec2"
    instance_type = "t2.micro"
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    subnet_ids = module.vpc.public_subnet_ids
    default_vpc = false
    vpc_id = module.vpc.vpc_id
}

module "pvt-instance" {
    name = "pvt-instance"
    source = "../../modules/ec2"
    pub_key_path = "${path.module}/aws.pub"
    instance_count = 1
    subnet_ids = module.vpc.private_subnet_ids
    default_vpc = false
    vpc_id = module.vpc.vpc_id
}
*/

####################################################
#
# Use non-default security group
#
###################################################

module "vpc" {
    name = "my-vpc"
    source = "../../modules/vpc"
    cidr = "10.0.0.0/16"
    public_subnets = [ { cidr = "10.0.1.0/24", az = "us-east-1a" } ]
    private_subnets = [ { cidr = "10.0.2.0/24", az = "us-east-1b" } ]
    auto_assign_public_ip = true
}

resource "aws_security_group"  "my_sg" {
    name = "my-security-group"
    vpc_id = module.vpc.vpc_id
     ingress {
       description = "SSH"
       from_port   = 22
       to_port     = 22
       protocol    = "TCP"
       cidr_blocks = ["0.0.0.0/0"]
    }
}

module "pub-instance" {
    name = "pub-instance"
    source = "../../modules/ec2"
    instance_type = "t2.micro"
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
    subnet_ids = module.vpc.public_subnet_ids
    default_vpc = false
    use_default_sg = false
    security_group_ids = [resource.aws_security_group.my_sg.id]
    vpc_id = module.vpc.vpc_id
}

module "pvt-instance" {
    name = "pvt-instance"
    source = "../../modules/ec2"
    pub_key_path = "${path.module}/aws.pub"
    instance_count = 1
    subnet_ids = module.vpc.private_subnet_ids
    default_vpc = false
    vpc_id = module.vpc.vpc_id
}
