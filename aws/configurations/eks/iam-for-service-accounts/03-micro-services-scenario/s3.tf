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


