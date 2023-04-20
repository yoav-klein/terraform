
########################################
# Elasticsearch domain
########################################

data "aws_caller_identity" "current" {}

resource "aws_elasticsearch_domain" "this" {
    domain_name = "my-elastic-domain"
    elasticsearch_version = "7.7"
    
    cluster_config {
        instance_type = "t3.medium.elasticsearch"
        instance_count = 2
        
    }
    
    vpc_options {
        subnet_ids = [ module.vpc.private_subnet_ids[0] ]
        security_group_ids = [ aws_security_group.opensearch.id ]
    }


    ebs_options {
        ebs_enabled = true
        volume_type = "gp2"
        volume_size = 20
    }
    access_policies = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": { "AWS": "*" },
            "Action": "es:*",
            "Resource": "arn:aws:es:us-east-1:${data.aws_caller_identity.current.account_id}:domain/my-elastic-domain/*"
        }]
    }
EOF
}
