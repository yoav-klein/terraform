terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
    
    helm = {
      source = "hashicorp/helm"
      version = "3.1.1"
    }

     kubernetes = {
      source = "hashicorp/kubernetes"
      version = "3.0.1"
    }

     argocd = {
      source = "argoproj-labs/argocd"
      version = "7.15.0"
    }
  }
}

provider "aws" {}

provider "kubernetes" {  
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "kubectl" {
  load_config_file       = false
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
      host                   = data.aws_eks_cluster.this.endpoint
      cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
      token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "argocd" {
    username = "admin"
    #server_addr = "aad4c4e34dade4ca481844d08ca9bfc3-1670300221.us-east-1.elb.amazonaws.com:443"
    port_forward = true
    password  = base64decode(data.kubernetes_secret_v1.argocd_admin_password.binary_data.password)
    insecure = true
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name

  depends_on = [aws_eks_cluster.this]
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name

  depends_on = [aws_eks_cluster.this]
}

data "kubernetes_secret_v1" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  binary_data  = {
    "password" = ""
  }

  depends_on = [helm_release.argocd]
}

#output "argocd_admin_password" {
#  value     = base64decode(data.kubernetes_secret_v1.argocd_admin_password.binary_data.password)
#  sensitive = true
#}
