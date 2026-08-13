
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
   
    helm = {
      source = "hashicorp/helm"
      version = ">3"
    }
  }
}

provider "helm" {
  kubernetes = {
      host                   = module.eks_cluster.cluster.endpoint
      cluster_ca_certificate = base64decode(module.eks_cluster.cluster.certificate_authority[0].data)
      token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
    name = module.eks_cluster.cluster.name
}


