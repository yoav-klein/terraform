
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
  }
}

provider "aws" { }

provider "helm" {
  kubernetes = {

    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}


########################################################
# You need an IAM role for the cluster 
# to access AWS services
########################################################

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster_role" {
  name               = "eks-cluster-example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

######################################################
# The cluster
######################################################


locals {
    kubernetes_version = "1.32"
}


resource "aws_eks_cluster" "this" {
    name = "my-cluster"
    role_arn = aws_iam_role.cluster_role.arn
    version = local.kubernetes_version
   
    vpc_config {
        subnet_ids = module.vpc.private_subnet_ids
        endpoint_private_access = true
        endpoint_public_access = true
    }
    

    depends_on = [
        aws_iam_role_policy_attachment.cluster_policy_attachment
    ]
    
}

data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.this.name

  depends_on = [aws_eks_cluster.this]
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name

  depends_on = [aws_eks_cluster.this]
}

#############################################################
#    Managed node group
#############################################################


#####################################
# Must create a IAM role with permissions
# for the nodes to use
#####################################

resource "aws_iam_role" "node_role" {
  name = "EKSNodeRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.node_role.name
}

#####################################
# The node group itself
####################################

resource "aws_eks_node_group" "this" {
    cluster_name = aws_eks_cluster.this.name
    node_role_arn = aws_iam_role.node_role.arn
    
    version = local.kubernetes_version
    
    scaling_config {
        desired_size = 2
        max_size = 2
        min_size = 1
    }

    subnet_ids = module.vpc.private_subnet_ids
    disk_size = 20
    instance_types = ["t3.medium"]
    node_group_name = "my-node-group"
    
    depends_on = [
        aws_iam_role_policy_attachment.worker_node_policy,
        aws_iam_role_policy_attachment.cni_policy,
        aws_iam_role_policy_attachment.ecr_policy,
        aws_nat_gateway.this        
    ]

}


######################################
# Metrics Server
######################################

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  namespace  = "kube-system"

}


######################################
# outputs
######################################

output "endpoint" {
    value = aws_eks_cluster.this.endpoint
}

