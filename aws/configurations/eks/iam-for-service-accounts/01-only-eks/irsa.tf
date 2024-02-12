
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
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:developer"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}

# The role
resource "aws_iam_role" "developer" {
  assume_role_policy = data.aws_iam_policy_document.assume_role_document.json
  name               = "developer"
}


##################################################
#
# S3 bucket
#
#################################################

resource "aws_s3_bucket" "this" {
  bucket = "my-tf-test-bucket-yoav12"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

output "s3_bucket_name" {
    value = aws_s3_bucket.this.id
}


# Policy to allow the role to read from S3 bucket
data "aws_iam_policy_document" "read_s3" {
  statement {
    actions = ["s3:ListBucket", "s3:GetObject"]
    effect  = "Allow"

    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_iam_policy" "read_s3" {
  name        = "ReadFromS3"
  path        = "/"
  description = "Test policy for IRSA"

  policy = data.aws_iam_policy_document.read_s3.json
}

resource "aws_iam_role_policy_attachment" "read_s3" {
  policy_arn = aws_iam_policy.read_s3.arn
  role       = aws_iam_role.developer.name
}
