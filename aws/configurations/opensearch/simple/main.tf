
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

provider "aws" {}

resource "aws_opensearch_domain" "this" {
  domain_name    = "example"
  engine_version = "OpenSearch_2.3"

  cluster_config {
    instance_type = "t3.medium.search"
  }
  
  ebs_options {
    ebs_enabled = true
    volume_size = 15
  }
    
 
  tags = {
    Domain = "TestDomain"
  }
}

