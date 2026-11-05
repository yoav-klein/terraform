



########################################################
# You need an IAM role for the cluster 
# to access AWS services
########################################################

data "aws_iam_policy_document" "cluster_role_trust_policy" {
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
  name               = "${var.cluster_name}-ClusterRole"
  assume_role_policy = data.aws_iam_policy_document.cluster_role_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

########################################################
# The cluster
########################################################


resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = local.kubernetes_version

  vpc_config {
    subnet_ids              = var.cluster_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
        authentication_mode = "API_AND_CONFIG_MAP"
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
  name = "${var.cluster_name}-ClusterNodeRole"

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
    desired_size = var.node_count
    max_size     = var.node_count
    min_size     = 1
  }


  subnet_ids      = var.node_subnet_ids
  disk_size       = 20
  instance_types  = ["t3.medium"]
  node_group_name = "${var.cluster_name}-NodeGroup"

  depends_on = [
    aws_eks_cluster.this,
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]

}

output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

