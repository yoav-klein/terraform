
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50"
    }
  }
}

provider "aws" {}

resource "aws_s3_bucket" "this" {
  bucket = "yoav-test-waf-logging"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.this]
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "public-read"

  depends_on = [aws_s3_bucket_public_access_block.this]
}


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

