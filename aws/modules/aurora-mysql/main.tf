
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}


resource "aws_security_group" "public" {
  name = "${var.name}-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "MySQL"
    from_port   = var.port
    to_port     = var.port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_subnet_group" "this" {
    name = "${var.name}-subnet-group"
    subnet_ids = var.subnet_ids
}


resource "aws_rds_cluster" "this" {
  db_subnet_group_name = aws_db_subnet_group.this.name
# availability_zones = 
  cluster_identifier = var.name
  port = var.port
  engine = "aurora-mysql"
  engine_mode = "provisioned"
  engine_version = var.engine_version
  master_username = var.username
  master_password = var.password
  vpc_security_group_ids = var.publicly_accessible ? [aws_security_group.public.id] : var.security_group_ids
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "this" {
    count = var.num_instances

    identifier = "example-instance${count.index}"
    publicly_accessible = var.publicly_accessible
    cluster_identifier = aws_rds_cluster.this.id
    instance_class = var.instance_class
    engine = aws_rds_cluster.this.engine
    engine_version = aws_rds_cluster.this.engine_version
}
