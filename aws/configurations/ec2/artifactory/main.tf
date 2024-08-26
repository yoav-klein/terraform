
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

module "vpc" {
    source = "../../../modules/vpc"
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
    from_port   = 8080
    to_port     = 8082
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
  algorithm = "RSA"
}

resource "local_sensitive_file" "private_key" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "${path.module}/private.key"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "jump-server-keypair1"
  public_key = tls_private_key.private_key.public_key_openssh

}


resource "aws_instance" "this" {
  ami                  = "ami-053b0d53c279acc90" # 'Ubuntu 22.04'
  key_name             = aws_key_pair.key_pair.key_name
  instance_type        = "t3.medium"
  vpc_security_group_ids = [ aws_security_group.this.id ]
  subnet_id = module.vpc.public_subnet_ids[0]
  user_data = <<EOF
#!/bin/bash
curl -L get.docker.com | bash
usermod -aG docker ubuntu
JFROG_HOME=/home/ubuntu/jfrog
mkdir -p $JFROG_HOME/artifactory/var/etc
cd $JFROG_HOME/artifactory/var/etc
touch ./system.yaml
chown -R 1030:1030 $JFROG_HOME/artifactory/var
chmod 777 $JFROG_HOME/artifactory/var

echo "docker run --name artifactory -v $JFROG_HOME/artifactory/var/:/var/opt/jfrog/artifactory -d -p 8081:8081 -p 8082:8082 releases-docker.jfrog.io/jfrog/artifactory-oss:7.59.23" > /home/ubuntu/run.sh
chown ubuntu:ubuntu /home/ubuntu/run.sh
chmod +x /home/ubuntu/run.sh

EOF

  tags = {
    Name = "Artifcatory"
  }

}

output "server_domain" {
    description = "Nginx domain name"
    value = aws_instance.this.public_dns
}
