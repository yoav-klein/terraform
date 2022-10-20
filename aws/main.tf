terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_security_group" "my_sg" {
    name = "my_sg"
    # vpc - defaults to the deafult vpc
    
    ingress {
        description = "ssh connectivity"
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_key_pair" "deployer" {
    key_name = "deployer-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDj0VBXKhB3oaip0ybENMGc7CBYoYIBTzZnqE/dv6OUuaFTa3b5r5Wk3hw+89cYBYltXMeQOGpuooqIySfAUaTxFdg9Gbwneukr6ItRP9D/urBiui4B9BPpxFhfiNxPNdXi1MraRBi304F0RAxN2kwjZoy8k/d2LQQPKkaFPd99FSFBaGvtx4jlur0Zz+2iS4wUz2x76FS9MNrJg5UzNb/6WAb/k2dRm+dQw3quB03vD4Nm9u2/hQOU951MijF/UvXjxkmEKVwX5468jspo79YsKdkN6PPG4S5c5gNC2nx2JWREeTerpbwVvzXRUuPdanyuhij7jlexwsiJYtqcWg7DeWv8m00BvOKIZ3+ANDqgtdya6KHAErQxnWKkZujU3jqz2C+i8ZwtaU0I/pQ3+f/QHSPG04HdD10VCg0i6IE42ntzXhgISMpK862NK7IE8pRPJHScTbx7gq2V4Mb0HU4uu5/LsE7p2CcO7bwqcZwEXPzb9Q5/JbmPHShH34vdXKk= yoav@yoav-VirtualBox"
}

resource "aws_instance" "app_server" {
  count = 2
  ami           = "ami-08c40ec9ead489470"
  key_name      = "${aws_key_pair.deployer.key_name}"
  instance_type = "t2.small"
  security_groups = ["${aws_security_group.my_sg.name}"]
  user_data = <<EOF
#!/bin/bash

  user_data = << EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
EOF

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

