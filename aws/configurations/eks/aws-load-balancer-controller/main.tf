
locals {
    cluster_name = "my-cluster"
}

##########################################################
# Create a VPC for the cluster

# the VPC contains 2 private subnets for the cluster
# and a public subnet for load balancers and whatever
##########################################################

module "vpc" {
  source = "../../../modules/vpc"
  name   = "k8s-vpc"
  cidr   = "10.0.0.0/16"
  private_subnets = [{
    az   = "us-east-1b"
    cidr = "10.0.1.0/24"
    },
    {
      az   = "us-east-1c"
      cidr = "10.0.2.0/24"
  }]
  public_subnets = [{
    az   = "us-east-1b",
    cidr = "10.0.3.0/24"
    },
    {
      az   = "us-east-1c",
      cidr = "10.0.4.0/24"
  }]
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

}

resource "aws_eip" "this" {
  vpc = true
}


resource "aws_nat_gateway" "this" {
  allocation_id     = aws_eip.this.allocation_id
  connectivity_type = "public"
  subnet_id         = module.vpc.public_subnet_ids[0]
}

resource "aws_route" "route_to_nat_gateway" {
  route_table_id         = module.vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.this.id
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

########################################################
# The cluster
########################################################

locals {
  kubernetes_version = "1.24"
}

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = local.kubernetes_version

  vpc_config {
    subnet_ids              = module.vpc.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }


  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy_attachment
  ]

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
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

#####################################
# The node group itself
####################################

resource "aws_eks_node_group" "this" {
  cluster_name  = aws_eks_cluster.this.name
  node_role_arn = aws_iam_role.node_role.arn

  version = local.kubernetes_version
  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 1
  }

  subnet_ids      = module.vpc.private_subnet_ids
  disk_size       = 20
  instance_types  = ["t3.medium"]
  node_group_name = "my-node-group"

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
    aws_nat_gateway.this
  ]

}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

