
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>4.60"
        }
    }
}   


provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "public_bucket" {
  bucket = "my-public-yoav-bucket"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.public_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "public_bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.this]
  bucket = aws_s3_bucket.public_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.public_bucket.arn}/*"
      }
    ]
  })
}

output "bucket_name" {
  value = aws_s3_bucket.public_bucket.bucket
}

