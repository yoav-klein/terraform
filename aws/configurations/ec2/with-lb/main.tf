

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
    instance_count = 2
}

data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = data.aws_availability_zones.available.names
  public_subnets  = ["10.0.10.0/24", "10.0.11.0/24"]
  private_subnets = ["10.0.1.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "ec2" {
    source = "../../modules/ec2"

    pub_key_path = "${path.module}/key.pub"

    default_vpc = false
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
    instance_count = local.instance_count
}

module "alb" {
    source = "../../modules/load-balancer"
    
    name = "my-alb"
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.public_subnets
}

resource "aws_lb_target_group_attachment" "attachment" {
  count = local.instance_count
  target_group_arn = module.alb.target_group_arns[0]
  target_id        = module.ec2.instance_ids[count.index]
  port             = 80
}

