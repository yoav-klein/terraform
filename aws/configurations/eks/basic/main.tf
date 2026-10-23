
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }
}

provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "../../../modules/vpc-v2"

    cidr = "10.0.0.0/16"
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
    create_nat_gateway = true
}

output "vpc" {
    value = module.vpc
}

output "private_subnets" {
    value = module.vpc.private_subnets[*].id
}

module "eks" {
    source = "../../../modules/eks"

    cluster_name = "simple"
    node_count = 1
    cluster_subnet_ids = module.vpc.private_subnets[*].id
    node_subnet_ids = module.vpc.private_subnets[*].id

}
