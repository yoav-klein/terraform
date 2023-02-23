
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

variable "domain" {
    default = "test-domain"
}

resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain
  engine_version = "OpenSearch_2.3"

  cluster_config {
    instance_type = "t3.medium.search"
    instance_count = 3
  }
  
  ebs_options {
    ebs_enabled = true
    volume_size = 15
  }
  
    access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": {"AWS": "${data.aws_caller_identity.current.arn}"},
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*"
    }
  ]
}
POLICY
 
  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  tags = {
    Domain = "TestDomain"
  }
}

