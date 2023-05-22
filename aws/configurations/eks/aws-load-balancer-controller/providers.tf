terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

    
  }
}

provider "aws" { }

provider "kubectl" {
    config_path = "~/.kube/config"
    config_context = aws_eks_cluster.this.arn
}
