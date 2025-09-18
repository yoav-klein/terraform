
###############################################################################
# Data sources for ${AWS::Partition}, ${AWS::Region}, ${AWS::AccountId}
###############################################################################
data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


###############################################################################
# Create the policy and role
###############################################################################

# the Karpenter Controller policy
data "template_file" "karpenter_controller_policy" {
    template = file("${path.root}/templates/karpenter-controller-policy.json.tpl")
    vars = {
        account_id = data.aws_caller_identity.current.account_id
        cluster_name = aws_eks_cluster.this.name
        region = data.aws_region.current.name
        node_role_arn = aws_iam_role.node_role.arn
    }
}

resource "aws_iam_policy" "karpenter_controller" {
  name   = "KarpenterControllerPolicy-${aws_eks_cluster.this.name}"
  policy = data.template_file.karpenter_controller_policy.rendered
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


###############################################################################
#   Karpenter Helm chart
###############################################################################

resource "helm_release" "karpenter" {
    name = "karpenter"
    repository = "oci://public.ecr.aws/karpenter"
    chart = "karpenter"
    version = local.karpenter_version
    namespace = "karpenter"
    create_namespace = true
    set = [
        {
            name  = "settings.clusterName"
            value = aws_eks_cluster.this.name
        },
        {
            name  = "settings.interruptionQueue"
            value = aws_eks_cluster.this.name
        },
        {
            name = "controller.resources.requests.cpu"
            value = "200m"
        },
        {
            name = "controller.resources.requests.memory"
            value = "512Mi"
        },
        {
            name = "controller.resources.limits.cpu"
            value = 1
        },
        {
            name = "controller.resources.limits.memory"
            value = "1Gi"
        },
        {
            name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
            value = aws_iam_role.karpenter_controller.arn
        },

    ]
    depends_on = [aws_eks_cluster.this] 
}


###############################################################################
#   NodePool and EC2NodeClass
###############################################################################

data "aws_ssm_parameter" "ami" {
    name = "/aws/service/eks/optimized-ami/${local.kubernetes_version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
}

data "kubectl_path_documents" "karpenter" {
    pattern = "${path.root}/templates/karpenter.yaml.tpl"
    vars = {
       node_role_name = aws_iam_role.node_role.name
       cluster_name = aws_eks_cluster.this.name
       cluster_security_group = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
       ami_id = data.aws_ssm_parameter.ami.value
    }
}

resource "kubectl_manifest" "karpenter" {
  count = length(data.kubectl_path_documents.karpenter.documents)

  yaml_body = element(data.kubectl_path_documents.karpenter.documents, count.index)

}
