
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50"
    }
  }
}

provider "aws" {}


#### S3 Bucket

resource "aws_s3_bucket" "this" {
  bucket = "mytestbucket-yoav13"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.this]
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
      }
    ]
  })
}


#### CloudFront

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  origin {
    domain_name = aws_s3_bucket.this.bucket_domain_name
    origin_id   = "s3_bucket"
  }
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3_bucket"
    viewer_protocol_policy = "allow-all"

    # CachingOptimized
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  web_acl_id = aws_wafv2_web_acl.this.arn
}

output "bucket_name" {
  description = "Bucket name"
  value       = aws_s3_bucket.this.id
}

output "cloudfront_url" {
  description = "Cloudfront URL"
  value       = aws_cloudfront_distribution.this.domain_name
}

