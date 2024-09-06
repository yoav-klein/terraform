
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65"
    }
     kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    http = {
        source = "hashicorp/http"
        version = "3.4.4"
    }
  }
}

provider "kubectl" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

provider "aws" { }


data "aws_eks_cluster_auth" "this" {
    name = aws_eks_cluster.this.name
}

