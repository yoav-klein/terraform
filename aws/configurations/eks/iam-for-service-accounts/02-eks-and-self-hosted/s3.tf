

resource "random_string" "random" {
  length  = 8
  special = false
  upper = false
}

####################################################
#
#   OIDC S3 Bucket
#
####################################################

resource "aws_s3_bucket" "oidc" {
  bucket = "oidc-bucket-${random_string.random.result}"

  tags = {
    Name        = "OIDC"
    Environment = "Dev"
  }
}


resource "aws_s3_bucket_public_access_block" "oidc" {
  bucket = aws_s3_bucket.oidc.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_access_policy" {
  bucket = aws_s3_bucket.oidc.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.oidc.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.oidc]
}

data "aws_region" "current" {}

data "template_file" "discovery" {
    template = file("${path.root}/templates/discovery.json")
    vars = {
        ISSUER_HOSTPATH = "s3.${data.aws_region.current.name}.amazonaws.com/${aws_s3_bucket.oidc.id}"
    }
}

resource "aws_s3_object" "discovery" {
  bucket = aws_s3_bucket.oidc.id
  key    = ".well-known/openid-configuration"
  content = data.template_file.discovery.rendered
}

resource "aws_s3_object" "keys" {
    bucket = aws_s3_bucket.oidc.id
    key    = "keys.json"
    source = "${path.root}/files/keys.json"
}

output "s3_oidc_bucket_domain_name" {
    value = aws_s3_bucket.oidc.bucket_domain_name
}


###############################################
#
#  content S3 bucket
#
#################################################

resource "aws_s3_bucket" "content" {
  bucket = "content-bucket-${random_string.random.result}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

output "s3_content_bucket_name" {
    value = aws_s3_bucket.content.id
}


# Policy to allow the role to read from S3 bucket
data "aws_iam_policy_document" "read_s3" {
  statement {
    actions = ["s3:ListBucket", "s3:GetObject"]
    effect  = "Allow"

    resources = ["${aws_s3_bucket.content.arn}/*"]
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

resource "aws_s3_object" "content" {
    bucket = aws_s3_bucket.content.id
    key = "content.txt"
    content = "IAM for Service Account Demo !"
}

