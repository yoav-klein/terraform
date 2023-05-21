
###################################################
#
# Create an OIDC provider configuration for the cluster
#
###################################################


# get the certificates for the provider in order to get the fingerprint
data "tls_certificate" "this" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}


resource "aws_iam_openid_connect_provider" "this" {
  url = data.tls_certificate.this.url
  thumbprint_list = data.tls_certificate.this.certificates[*].sha1_fingerprint
  client_id_list = ["sts.amazonaws.com"]
}


################################################
#
# Create a role that allows the cluster ServiceAccounts to assume
#
# This allows the  ServiceAccount 
# in the default namespace to assume the role
#
###############################################


# The trust policy of the role
data "aws_iam_policy_document" "assume_role_document" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }


    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

# The role
resource "aws_iam_role" "ebs_csi" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_document.json
  name               = "AmazonEKS_EBS_CSI_DriverRole"
}


resource "aws_eks_addon" "ebs-csi" {
    cluster_name = aws_eks_cluster.this.name
    addon_name = "aws-ebs-csi-driver"
    service_account_role_arn = aws_iam_role.ebs_csi.arn
}
