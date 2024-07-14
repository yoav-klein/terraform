
######################################################
#  OpenSearch domain
######################################################

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_service_linked_role" "os" {
    aws_service_name = "es.amazonaws.com"
    description      = "Allows Amazon OS to manage AWS resources for a domain on your behalf."
}

resource "aws_opensearch_domain" "this" {
  domain_name    = "eks-opensearch-domain"
  engine_version = "OpenSearch_1.3"

  cluster_config {
    instance_type = "t3.medium.search"
    instance_count = 3
  }
    
  vpc_options {
    subnet_ids = [ module.vpc.private_subnet_ids[0] ]
    security_group_ids = [ aws_security_group.opensearch.id ]
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

  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": {"AWS": "*"},
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/eks-opensearch-domain/*"
    }
  ]
}
POLICY
 
  tags = {
    Domain = "TestDomain"
  }

  depends_on = [aws_iam_service_linked_role.os]
}

output "opensearch_endpoint" {
description = "Domain endpoint"
value = aws_opensearch_domain.this.endpoint
} 

output "dashboard_endpoint" {
    description = "OpenSearch Dashboard endpoint"
    value = aws_opensearch_domain.this.dashboard_endpoint
}
