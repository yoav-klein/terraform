
module "vpc4" {
    source = "../../../modules/vpc"
    name = "vpc4"
    cidr = "10.3.0.0/16"
    public_subnets = [{ 
        az = "us-east-1b"
        cidr = "10.3.1.0/24"
    }]
    private_subnets = [{
        az = "us-east-1a",
        cidr = "10.3.2.0/24"
    }]
}


resource "aws_security_group" "vpc4" {
  name = "BasicSG"
  vpc_id = module.vpc4.vpc_id

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

resource "tls_private_key" "vpc4" {
    algorithm = "RSA"
}

resource "local_file" "vpc4" {
    content = tls_private_key.vpc4.private_key_pem
    filename = "${path.root}/private4.key"
    file_permission = "0600"
}

resource "aws_key_pair" "vpc4" {
  key_name   = "vpc4"
  public_key = tls_private_key.vpc4.public_key_openssh
}

resource "aws_instance" "vpc4" {
  ami                  = local.amis["ubuntu"]
  key_name             = aws_key_pair.vpc4.key_name
  instance_type        = "t2.medium"
  vpc_security_group_ids = [ aws_security_group.vpc4.id ]
  subnet_id = module.vpc4.public_subnet_ids[0]
  
  tags = {
    Name = "VPC4"
  }

}

output "vpc4_ec2_public_domain" {
    description = "VPC4 EC2 public domain name"
    value = aws_instance.vpc4.public_dns
}

output "vpc4_ec2_private_domain" {
    description = "VPC4 EC2 private domain name"
    value = aws_instance.vpc4.private_dns
}

