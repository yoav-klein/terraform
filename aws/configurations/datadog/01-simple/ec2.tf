
locals {
    amis = {
        ubuntu = "ami-0f1bae6c3bedcc3b5"
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
  name = "BasicSG"
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

resource "aws_instance" "medium" {
  count = 2
  
  ami                  = local.amis["ubuntu"]
  key_name             = aws_key_pair.this.key_name
  instance_type        = "t2.medium"
  vpc_security_group_ids = [ aws_security_group.this.id ]
  subnet_id = module.vpc.public_subnet_ids[0]
  
  monitoring = true
  tags = {
    Name = "Medium"
  }

}

resource "aws_instance" "small" {
  count = 2
 
  ami                  = local.amis["ubuntu"]
  key_name             = aws_key_pair.this.key_name
  instance_type        = "t2.small"
  vpc_security_group_ids = [ aws_security_group.this.id ]
  subnet_id = module.vpc.public_subnet_ids[0]
  
  #monitoring = true
  tags = {
    Name = "Small"
  }

}


output "small" {
    description = "Domain name"
    value = aws_instance.small[*].public_dns
}

output "medium" {
    description = "Domain name"
    value = aws_instance.medium[*].public_dns
}
