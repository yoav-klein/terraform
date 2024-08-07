

module "vpc2" {
    source = "../../../modules/vpc"
    name = "vpc2"
    cidr = "10.1.0.0/16"
    public_subnets = [{ 
        az = "us-east-1b"
        cidr = "10.1.1.0/24"
    }]
    private_subnets = [{
        az = "us-east-1a",
        cidr = "10.1.2.0/24"
    }]
}


resource "aws_security_group" "vpc2" {
  name = "BasicSG"
  vpc_id = module.vpc2.vpc_id

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

resource "tls_private_key" "vpc2" {
    algorithm = "RSA"
}

resource "local_file" "vpc2" {
    content = tls_private_key.vpc2.private_key_pem
    filename = "${path.root}/private2.key"
    file_permission = "0600"
}

resource "aws_key_pair" "vpc2" {
  key_name   = "vpc2"
  public_key = tls_private_key.vpc2.public_key_openssh
}

resource "aws_instance" "vpc2" {
  ami                  = local.amis["ubuntu"]
  key_name             = aws_key_pair.vpc2.key_name
  instance_type        = "t2.medium"
  vpc_security_group_ids = [ aws_security_group.vpc2.id ]
  subnet_id = module.vpc2.public_subnet_ids[0]
  
  tags = {
    Name = "VPC2"
  }

}



output "vpc2_ec2_public_domain" {
    description = "VPC2 EC2 public domain name"
    value = aws_instance.vpc2.public_dns
}

output "vpc2_ec2_private_domain" {
    description = "VPC2 EC2 private domain name"
    value = aws_instance.vpc2.private_dns
}

