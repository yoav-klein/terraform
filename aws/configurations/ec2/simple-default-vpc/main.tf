terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

provider "aws" {}


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

# Security Group
resource "aws_security_group" "this" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allowing all IPs to connect via SSH
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allowing all IPs to connect via HTTP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allowing all outbound traffic
  }

  tags = {
    Name = "allow_ssh_http"
  }
}


resource "aws_instance" "this" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.small"
  
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name = aws_key_pair.this.key_name

  tags = {
    Name = "SimpleEC2"
  }

}


output "domain_name" {
    value = aws_instance.this.public_dns
}
