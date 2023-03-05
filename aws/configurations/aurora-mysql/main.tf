
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
    port = 3306
}

provider "aws" {}

resource "aws_security_group" "this" {
  name = "example-security-group"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "MySQL"
    from_port   = var.port
    to_port     = var.port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_db_subnet_group" "this" {
    name = "subnet_group"
    subnet_ids = data.aws_subnets.default.ids
}


resource "aws_rds_cluster" "this" {
  db_subnet_group_name = aws_db_subnet_group.this.name
# availability_zones = 
  cluster_identifier = "kuku"
  port = local.port
  engine = "aurora-mysql"
  engine_mode = "provisioned"
  engine_version = "5.7.mysql_aurora.2.11.1"
  master_username = "admin"
  master_password = "yoavklein3"
  vpc_security_group_ids = [aws_security_group.this.id]
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "this" {
    count = 3

    identifier = "example-instance${count.index}"
    publicly_accessible = true
    cluster_identifier = aws_rds_cluster.this.id
    instance_class = var.instance_class
    engine = aws_rds_cluster.this.engine
    engine_version = aws_rds_cluster.this.engine_version
}
