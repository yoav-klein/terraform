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
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
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


##############################
# cert-manager
##############################

data "kubectl_file_documents" "cert_manager" {
  content = file("manifests/cert-manager.yaml")
}

# need to create the namespace first, since you might have a race condition
resource "kubectl_manifest" "cert_manager_ns" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
    name: cert-manager
YAML

  depends_on = [aws_eks_cluster.this]
}

resource "time_sleep" "wait_for_cert_manager_ns" {
  depends_on = [kubectl_manifest.cert_manager_ns]

  create_duration = "60s"
}

resource "kubectl_manifest" "cert_manager" {
  count = length(data.kubectl_file_documents.cert_manager.documents)

  yaml_body = element(data.kubectl_file_documents.cert_manager.documents, count.index)

  depends_on = [time_sleep.wait_for_cert_manager_ns, aws_eks_node_group.this]
}

###############################
# AWS Load Balancer Controller
###############################


data "kubectl_file_documents" "ingress_class" {
  content = file("manifests/ingclass.yaml")
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

  depends_on = [aws_eks_cluster.this, aws_iam_role.aws_load_balancer_controller]
}

resource "helm_release" "aws_load_balancer_controller" {
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
        value = aws_eks_cluster.this.name
    },
    {
        name = "serviceAccount.create"
        value = false
    },
    {
        name = "serviceAccount.name"
        value = "aws-load-balancer-controller" 
    }
  ]

  depends_on = [kubectl_manifest.cert_manager]
}
