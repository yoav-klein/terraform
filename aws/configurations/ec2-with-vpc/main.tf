

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}


data "aws_availability_zones" "available" {
  state = "available"
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
  
  azs             = data.aws_availability_zones.available.names
  public_subnets  = ["10.0.1.0/24"]

  enable_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "myInstance" {
    source = "../../modules/ec2"
    default_vpc = false
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.public_subnets
    pub_key_path="${path.module}/aws.pub"
    instance_count = 1
}
