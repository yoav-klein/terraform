##################################################
# IAM Infrastructure
##################################################

data "http" "aws_load_balancer_controller_iam_policy_document" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v${local.aws_load_balancer_controller_version}/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = data.http.aws_load_balancer_controller_iam_policy_document.response_body
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks.openid_connect_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.openid_connect_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.openid_connect_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_role_policy" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}



#####################################################
#
# Insatll manifests in the cluster - cert-manager and 
# the AWS Load Balancer controller controller
#
#####################################################


###############################
# AWS Load Balancer Controller
###############################


#data "kubectl_file_documents" "ingress_class" {
#  content = file("manifests/ingclass.yaml")
#}

resource "time_sleep" "wait_for_access_policy" {
    create_duration = "20s"

    depends_on = [aws_eks_access_policy_association.admin]
}


resource "kubectl_manifest" "service_account_for_alb" {
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.aws_load_balancer_controller.arn}
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
YAML

  depends_on = [ time_sleep.wait_for_access_policy ]
}

resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [ time_sleep.wait_for_access_policy ]

  name  = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart = "aws-load-balancer-controller"
  namespace = "kube-system"
  set = [
    {
        name = "vpcId",         # pods can't access instance metadata (for some reason, don't care), so we need to tell it the VPC ID
        value = module.vpc.vpc_id
    },
    {
        name = "clusterName"
        value = module.eks.cluster.name
    },
    {
        name = "serviceAccount.create"
        value = false
    },
    {
        name = "serviceAccount.name"
        value = "aws-load-balancer-controller" 
    },
    {
        name = "logLevel"
        value = "debug"
    }
  ]
}
