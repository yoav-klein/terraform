
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

module "vpc" {
    source = "../../../../modules/vpc"
    name = "my_vpc"
    cidr = "10.0.0.0/16"
    public_subnets = [{ 
        az = "us-east-1b"
        cidr = "10.0.1.0/24"
    }, {
        az = "us-east-1a"
        cidr = "10.0.2.0/24"
    }, {
        az = "us-east-1c"
        cidr = "10.0.3.0/24"
    }]
}

locals {
    amis = {
        ubuntu = "ami-0f1bae6c3bedcc3b5"
    }
}


resource "aws_security_group" "servers" {
  name   = "server-security-group"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "TCP"
    description     = "Echo server"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8090
    to_port         = 8090
    description     = "Health check port"
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    description = "SSH"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}



resource "tls_private_key" "this" {
    algorithm = "RSA"
}

resource "local_file" "private_key" {
    content = tls_private_key.this.private_key_pem
    filename = "${path.root}/private.key"
    file_permission = "0600"
}

resource "aws_key_pair" "this" {
  key_name   = "my-keys"
  public_key = tls_private_key.this.public_key_openssh
}


resource "aws_launch_template" "this" {
  name_prefix   = "foobar"
  image_id      = local.amis["ubuntu"]
  instance_type = "t2.micro"
  user_data     = base64encode(file("${path.module}/run-app.sh"))
  vpc_security_group_ids = [aws_security_group.servers.id]
  key_name = aws_key_pair.this.key_name
}


resource "aws_autoscaling_group" "this" {
  name = "my-auto-scaling-group"    

  desired_capacity   = 3
  max_size           = 5
  min_size           = 1
   
  vpc_zone_identifier = module.vpc.public_subnet_ids

  target_group_arns = [aws_lb_target_group.this.arn]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    replace_triggered_by = [ aws_launch_template.this ]
  }
}


