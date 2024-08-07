
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

locals {
    amis = {
        ubuntu = "ami-0f1bae6c3bedcc3b5"
    }
}


module "vpc1" {
    source = "../../../modules/vpc"
    name = "vpc1"
    cidr = "10.0.0.0/16"
    public_subnets = [{ 
        az = "us-east-1b"
        cidr = "10.0.1.0/24"
    }]
    private_subnets = [{
        az = "us-east-1a",
        cidr = "10.0.2.0/24"
    }]
}


resource "aws_security_group" "vpc1" {
  name = "BasicSG"
  vpc_id = module.vpc1.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
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

resource "tls_private_key" "vpc1" {
    algorithm = "RSA"
}

resource "local_file" "vpc1" {
    content = tls_private_key.vpc1.private_key_pem
    filename = "${path.root}/private1.key"
    file_permission = "0600"
}

resource "aws_key_pair" "vpc1" {
  key_name   = "vpc1"
  public_key = tls_private_key.vpc1.public_key_openssh
}

resource "aws_instance" "vpc1" {
  ami                  = local.amis["ubuntu"]
  key_name             = aws_key_pair.vpc1.key_name
  instance_type        = "t2.medium"
  vpc_security_group_ids = [ aws_security_group.vpc1.id ]
  subnet_id = module.vpc1.public_subnet_ids[0]
  
  tags = {
    Name = "VPC1"
  }

}

output "vpc1_ec2_public_domain" {
    description = "VPC1 EC2 public domain name"
    value = aws_instance.vpc1.public_dns
}

output "vpc1_ec2_private_domain" {
    description = "VPC1 EC2 private domain name"
    value = aws_instance.vpc1.private_dns
}

