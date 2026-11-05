
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
    node_count = 2
    cluster_subnet_ids = module.vpc.private_subnets[*].id
    node_subnet_ids = module.vpc.private_subnets[*].id

}

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "admin" {
  cluster_name      = module.eks.cluster.name
  principal_arn     = data.aws_caller_identity.current.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = module.eks.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn

  access_scope {
    type       = "cluster"
  }
}


resource "aws_eks_access_entry" "root" {
  cluster_name      = module.eks.cluster.name
  principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "root" {
  cluster_name  = module.eks.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"


  access_scope {
    type       = "cluster"
  }
}

