

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {}

module "vpc" {
  source   = "../../modules/vpc"
  name = "my_vpc"
  cidr     = "10.0.0.0/16"
  private_subnets = [{
    az   = "us-east-1b"
    cidr = "10.0.1.0/24"
    },
    {
      az   = "us-east-1c"
      cidr = "10.0.2.0/24"
    },{
      az   = "us-east-1d"
      cidr = "10.0.3.0/24"
  }]
  public_subnets = [{
    az   = "us-east-1a",
    cidr = "10.0.4.0/24"
  }]
}

resource "aws_elasticache_subnet_group" "this" {
    name = "my-subnet-group"
    subnet_ids = module.vpc.private_subnet_ids
    
}

resource "aws_elasticache_parameter_group" "this" {
  name   = "cache-params"
  family = "redis7"

  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }
}

resource "aws_elasticache_replication_group" "this" {
    replication_group_id = "my-redis-cluster"
    description = "Example cluster"
    
    multi_az_enabled = true
    # automatic_failover_enabled must be true if multi_az_enalbed is true
    automatic_failover_enabled = true
    node_type = "cache.r6g.large"
    engine = "redis"
    engine_version = "7.0"
    port = 6379
    subnet_group_name = aws_elasticache_subnet_group.this.name
    # num_cache_clusters in the number of nodes in the cluster
    num_cache_clusters = 3
    security_group_ids = [aws_security_group.redis_ec2.id]
    auto_minor_version_upgrade = true
    parameter_group_name = aws_elasticache_parameter_group.this.name
    #transit_encryption_enabled = true
    #at_rest_encryption_enabled = true
    
}

output "redis_host" {
    description = "Redis host"
    value = aws_elasticache_replication_group.this.primary_endpoint_address
}



