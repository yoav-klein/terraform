
###############################################################################
# Data sources for ${AWS::Partition}, ${AWS::Region}, ${AWS::AccountId}
###############################################################################
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


###############################################################################
# IAM Policy JSON
###############################################################################
locals {
  karpenter_controller_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowScopedEC2InstanceAccessActions"
        Effect   = "Allow"
        Resource = [
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}::image/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}::snapshot/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:security-group/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:subnet/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:capacity-reservation/*",
        ]
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
        ]
      },
      {
        Sid      = "AllowScopedEC2LaunchTemplateAccessActions"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:launch-template/*"
        Action   = ["ec2:RunInstances", "ec2:CreateFleet"]
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned"
          }
          StringLike = {
            "aws:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        }
      },
      {
        Sid      = "AllowScopedEC2InstanceActionsWithTags"
        Effect   = "Allow"
        Resource = [
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:fleet/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:instance/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:volume/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:network-interface/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:launch-template/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:spot-instances-request/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:capacity-reservation/*",
        ]
        Action = [
          "ec2:RunInstances",
          "ec2:CreateFleet",
          "ec2:CreateLaunchTemplate",
        ]
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned",
            "aws:RequestTag/eks:eks-cluster-name"  = aws_eks_cluster.this.name,
          }
          StringLike = {
            "aws:RequestTag/karpenter.sh/nodepool" = "*"
          }
        }
      },
      {
        Sid      = "AllowScopedResourceCreationTagging"
        Effect   = "Allow"
        Resource = [
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:fleet/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:instance/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:volume/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:network-interface/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:launch-template/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:spot-instances-request/*",
        ]
        Action = "ec2:CreateTags"
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned",
            "aws:RequestTag/eks:eks-cluster-name"                         = aws_eks_cluster.this.name,
            "ec2:CreateAction"                                            = ["RunInstances", "CreateFleet", "CreateLaunchTemplate"],
          }
          StringLike = {
            "aws:RequestTag/karpenter.sh/nodepool" = "*"
          }
        }
      },
      {
        Sid      = "AllowScopedResourceTagging"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:instance/*"
        Action   = "ec2:CreateTags"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned",
          }
          StringLike = {
            "aws:ResourceTag/karpenter.sh/nodepool" = "*"
          }
          StringEqualsIfExists = {
            "aws:RequestTag/eks:eks-cluster-name" = aws_eks_cluster.this.name
          }
          "ForAllValues:StringEquals" = {
            "aws:TagKeys" = ["eks:eks-cluster-name", "karpenter.sh/nodeclaim", "Name"]
          }
        }
      },
      {
        Sid      = "AllowScopedDeletion"
        Effect   = "Allow"
        Resource = [
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:instance/*",
          "arn:${data.aws_partition.current.partition}:ec2:${data.aws_region.current.name}:*:launch-template/*",
        ]
        Action = ["ec2:TerminateInstances", "ec2:DeleteLaunchTemplate"]
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned",
          }
          StringLike = {
            "aws:ResourceTag/karpenter.sh/nodepool" = "*"
          }
        }
      },
      {
        Sid    = "AllowRegionalReadActions"
        Effect = "Allow"
        Resource = "*"
        Action = [
          "ec2:DescribeCapacityReservations",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
        ]
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = data.aws_region.current.name
          }
        }
      },
      {
        Sid      = "AllowSSMReadActions"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}::parameter/aws/service/*"
        Action   = "ssm:GetParameter"
      },
      {
        Sid      = "AllowPricingReadActions"
        Effect   = "Allow"
        Resource = "*"
        Action   = "pricing:GetProducts"
      },
      {
        Sid      = "AllowPassingInstanceRole"
        Effect   = "Allow"
        Resource = aws_iam_role.node_role.arn
        Action   = "iam:PassRole"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = ["ec2.amazonaws.com", "ec2.amazonaws.com.cn"]
          }
        }
      },
      {
        Sid      = "AllowScopedInstanceProfileCreationActions"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
        Action   = ["iam:CreateInstanceProfile"]
        Condition = {
          StringEquals = {
            "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned",
            "aws:RequestTag/eks:eks-cluster-name"                         = aws_eks_cluster.this.name,
            "aws:RequestTag/topology.kubernetes.io/region"               = data.aws_region.current.name,
          }
          StringLike = {
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid      = "AllowScopedInstanceProfileTagActions"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
        Action   = ["iam:TagInstanceProfile"]
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"  = "owned",
            "aws:ResourceTag/topology.kubernetes.io/region"              = data.aws_region.current.name,
            "aws:RequestTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}"   = "owned",
            "aws:RequestTag/eks:eks-cluster-name"                        = aws_eks_cluster.this.name,
            "aws:RequestTag/topology.kubernetes.io/region"               = data.aws_region.current.name,
          }
          StringLike = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass"  = "*",
            "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass"   = "*",
          }
        }
      },
      {
        Sid      = "AllowScopedInstanceProfileActions"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
        Action   = [
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:DeleteInstanceProfile",
        ]
        Condition = {
          StringEquals = {
            "aws:ResourceTag/kubernetes.io/cluster/${aws_eks_cluster.this.name}" = "owned",
            "aws:ResourceTag/topology.kubernetes.io/region"             = data.aws_region.current.name,
          }
          StringLike = {
            "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass" = "*"
          }
        }
      },
      {
        Sid      = "AllowInstanceProfileReadActions"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:instance-profile/*"
        Action   = "iam:GetInstanceProfile"
      },
      {
        Sid      = "AllowUnscopedInstanceProfileListAction"
        Effect   = "Allow"
        Resource = "*"
        Action   = "iam:ListInstanceProfiles"
      },
      {
        Sid      = "AllowAPIServerEndpointDiscovery"
        Effect   = "Allow"
        Resource = "arn:${data.aws_partition.current.partition}:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${aws_eks_cluster.this.name}"
        Action   = "eks:DescribeCluster"
      },
    ]
  })
}

###############################################################################
# Create the policy and role
###############################################################################

# the policy
resource "aws_iam_policy" "karpenter_controller" {
  name   = "KarpenterControllerPolicy-${aws_eks_cluster.this.name}"
  policy = local.karpenter_controller_policy
}

# The trust policy of the role
data "aws_iam_policy_document" "assume_role_document_karpenter_controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {
    name = "KarpenterRole-${aws_eks_cluster.this.name}"
    assume_role_policy = data.aws_iam_policy_document.assume_role_document_karpenter_controller.json
}

resource "aws_iam_role_policy_attachment" "karpenter_role_policy_attachment" {
  policy_arn = aws_iam_policy.karpenter_controller.arn
  role       = aws_iam_role.karpenter_controller.name
}

resource "aws_security_group" "karpenter" {
    name = "karpenter"
    description = "Security group for Karpenter-created instances"
    tags = {
        "karpenter.sh/discovery" = aws_eks_cluster.this.name
    }
}
