

##########################################################
# Create a VPC for the cluster

# the VPC contains 2 private subnets for the cluster
# and a public subnet for load balancers and whatever
##########################################################

module "vpc" {
  source = "../../../modules/vpc-v2"
  name   = local.prefix
  cidr   = "10.0.0.0/16"
  private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  public_subnets = ["10.0.2.0/24", "10.0.3.0/24"]
  create_nat_gateway = true

  #private_subnet_tags = {
  #  "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #  "kubernetes.io/role/internal-elb"             = 1
  #}
  #public_subnet_tags = {
  #  "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  #  "kubernetes.io/role/elb"                      = 1
  #}

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
  name               = "${local.prefix}-ClusterRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

########################################################
# The cluster
########################################################


resource "aws_eks_cluster" "this" {
  name     = local.prefix
  role_arn = aws_iam_role.cluster_role.arn
  version  = local.kubernetes_version

  vpc_config {
    subnet_ids              = module.vpc.private_subnets[*].id
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
  name = "${local.prefix}-EKSNodeRole"

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
    desired_size = local.node_count
    max_size     = local.node_count
    min_size     = 1
  }

  subnet_ids      = module.vpc.private_subnets[*].id
  disk_size       = 20
  instance_types  = ["t3.medium"]
  node_group_name = "my-node-group"

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy,
    module.vpc
  ]

}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

