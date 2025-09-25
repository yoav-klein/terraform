{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowScopedEC2InstanceAccessActions",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${region}::image/*",
        "arn:aws:ec2:${region}::snapshot/*",
        "arn:aws:ec2:${region}:*:security-group/*",
        "arn:aws:ec2:${region}:*:subnet/*",
        "arn:aws:ec2:${region}:*:capacity-reservation/*"
      ],
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ]
    },
    {
      "Sid": "AllowScopedEC2LaunchTemplateAccessActions",
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:${region}:*:launch-template/*",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedEC2InstanceActionsWithTags",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${region}:*:fleet/*",
        "arn:aws:ec2:${region}:*:instance/*",
        "arn:aws:ec2:${region}:*:volume/*",
        "arn:aws:ec2:${region}:*:network-interface/*",
        "arn:aws:ec2:${region}:*:launch-template/*",
        "arn:aws:ec2:${region}:*:spot-instances-request/*",
        "arn:aws:ec2:${region}:*:capacity-reservation/*"
      ],
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet",
        "ec2:CreateLaunchTemplate"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${cluster_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${cluster_name}"
        },
        "StringLike": {
          "aws:RequestTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedResourceCreationTagging",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${region}:*:fleet/*",
        "arn:aws:ec2:${region}:*:instance/*",
        "arn:aws:ec2:${region}:*:volume/*",
        "arn:aws:ec2:${region}:*:network-interface/*",
        "arn:aws:ec2:${region}:*:launch-template/*",
        "arn:aws:ec2:${region}:*:spot-instances-request/*"
      ],
      "Action": "ec2:CreateTags",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${cluster_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${cluster_name}",
          "ec2:CreateAction": [
            "RunInstances",
            "CreateFleet",
            "CreateLaunchTemplate"
          ]
        },
        "StringLike": {
          "aws:RequestTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedResourceTagging",
      "Effect": "Allow",
      "Resource": "arn:aws:ec2:${region}:*:instance/*",
      "Action": "ec2:CreateTags",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        },
        "StringEqualsIfExists": {
          "aws:RequestTag/eks:eks-cluster-name": "${cluster_name}"
        },
        "ForAllValues:StringEquals": {
          "aws:TagKeys": [
            "eks:eks-cluster-name",
            "karpenter.sh/nodeclaim",
            "Name"
          ]
        }
      }
    },
    {
      "Sid": "AllowScopedDeletion",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${region}:*:instance/*",
        "arn:aws:ec2:${region}:*:launch-template/*"
      ],
      "Action": [
        "ec2:TerminateInstances",
        "ec2:DeleteLaunchTemplate"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowRegionalReadActions",
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "ec2:DescribeCapacityReservations",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "${region}"
        }
      }
    },
    {
      "Sid": "AllowSSMReadActions",
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:${region}::parameter/aws/service/*",
      "Action": "ssm:GetParameter"
    },
    {
      "Sid": "AllowPricingReadActions",
      "Effect": "Allow",
      "Resource": "*",
      "Action": "pricing:GetProducts"
    },
    {
      "Sid": "AllowInterruptionQueueActions",
      "Effect": "Allow",
      "Resource": "${karpenter_interruption_queue_arn}",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ]
    },
    {
      "Sid": "AllowPassingInstanceRole",
      "Effect": "Allow",
      "Resource": "${node_role_arn}",
      "Action": "iam:PassRole",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "ec2.amazonaws.com.cn"
          ]
        }
      }
    },
    {
      "Sid": "AllowScopedInstanceProfileCreationActions",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${account_id}:instance-profile/*",
      "Action": [
        "iam:CreateInstanceProfile"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${cluster_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${cluster_name}",
          "aws:RequestTag/topology.kubernetes.io/region": "${region}"
        },
        "StringLike": {
          "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedInstanceProfileTagActions",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${account_id}:instance-profile/*",
      "Action": [
        "iam:TagInstanceProfile"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}": "owned",
          "aws:ResourceTag/topology.kubernetes.io/region": "${region}",
          "aws:RequestTag/kubernetes.io/cluster/${cluster_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${cluster_name}",
          "aws:RequestTag/topology.kubernetes.io/region": "${region}"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
          "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedInstanceProfileActions",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${account_id}:instance-profile/*",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:DeleteInstanceProfile"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${cluster_name}": "owned",
          "aws:ResourceTag/topology.kubernetes.io/region": "${region}"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
        }
      }
    },
    {
      "Sid": "AllowInstanceProfileReadActions",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${account_id}:instance-profile/*",
      "Action": "iam:GetInstanceProfile"
    },
    {
      "Sid": "AllowUnscopedInstanceProfileListAction",
      "Effect": "Allow",
      "Resource": "*",
      "Action": "iam:ListInstanceProfiles"
    },
    {
      "Sid": "AllowAPIServerEndpointDiscovery",
      "Effect": "Allow",
      "Resource": "arn:aws:eks:${region}:${account_id}:cluster/${cluster_name}",
      "Action": "eks:DescribeCluster"
    }
  ]
}

