
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


resource "aws_opensearch_domain" "this" {
  domain_name    = "example"
  engine_version = "OpenSearch_2.3"

  cluster_config {
    instance_type = "t3.medium.search"
  }
 
  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }
 
  ebs_options {
    ebs_enabled = true
    volume_size = 15
  }

# this access policy is not allowed since it's too permissive
/*
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": {"AWS": "*"},
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/example/*"
    }
  ]
}
POLICY
*/  
 
  tags = {
    Domain = "TestDomain"
  }
}

