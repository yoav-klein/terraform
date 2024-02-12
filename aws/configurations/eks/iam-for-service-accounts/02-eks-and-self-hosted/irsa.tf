
###################################################
#
# Create an OIDC provider configuration for EKS cluster
#
###################################################


# get the certificates for the provider in order to get the fingerprint
data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}


resource "aws_iam_openid_connect_provider" "eks" {
  url = data.tls_certificate.eks.url
  thumbprint_list = data.tls_certificate.eks.certificates[*].sha1_fingerprint
  client_id_list = ["sts.amazonaws.com"]
}


###################################################
#
# Create an OIDC provider configuration for the Microk8s cluster
#
###################################################


# get the certificates for the provider in order to get the fingerprint
data "tls_certificate" "microk8s" {
  url = "https://s3.${data.aws_region.current.name}.amazonaws.com"
}

resource "aws_iam_openid_connect_provider" "microk8s" {
  url = "${data.tls_certificate.microk8s.url}/${aws_s3_bucket.oidc.id}"
  thumbprint_list = data.tls_certificate.microk8s.certificates[*].sha1_fingerprint
  client_id_list = ["sts.amazonaws.com"]
}




################################################
#
# Create a role that allows the cluster ServiceAccounts to assume
#
# This allows the "developer" ServiceAccount 
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
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:developer"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
   statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "s3.us-east-1.amazonaws.com/my-yoav-oidc-bucket:sub"
      values   = ["system:serviceaccount:default:developer"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.microk8s.arn]
      type        = "Federated"
    }
  }

}

# The role
resource "aws_iam_role" "developer" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_document.json
  name               = "developer"
}


