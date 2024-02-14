
module "vpc" {
    source = "../../modules/vpc"
    name = "my_vpc"
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


resource "aws_security_group" "this" {
  name = "nginx-server"
  vpc_id = module.vpc.vpc_id

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

resource "tls_private_key" "private_key" {
  algorithm   = "RSA"

}

resource "local_sensitive_file" "private_key" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "${path.module}/private.key"
}

resource "aws_key_pair" "this" {
  key_name   = "jump-server-keypair1"
  public_key = tls_private_key.private_key.public_key_openssh

}


resource "aws_instance" "this" {
  ami                  = "ami-053b0d53c279acc90" # Ubuntu 22.04
  key_name             = aws_key_pair.this.key_name
  instance_type        = "t2.small"
  vpc_security_group_ids = [ aws_security_group.this.id ]
  subnet_id = module.vpc.public_subnet_ids[0]
  user_data = <<EOF
#!/bin/bash
apt-get update
apt-get install -y nginx
EOF

  tags = {
    Name = "Nginx"
  }

}

output "server_domain" {
    description = "Nginx domain name"
    value = aws_instance.this.public_dns
}
