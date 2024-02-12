
resource "aws_security_group" "ec2" {
  name = "nginx-server"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "microk8s" {
  key_name   = "jump-server-keypair1"
  public_key = tls_private_key.private_key.public_key_openssh

}


resource "aws_instance" "microk8s" {
  ami                  = "ami-053b0d53c279acc90" # Ubuntu 22.04
  key_name             = aws_key_pair.microk8s.key_name
  instance_type        = "t2.small"
  vpc_security_group_ids = [ aws_security_group.ec2.id ]
  subnet_id = module.vpc.public_subnet_ids[0]
  
  tags = {
    Name = "Microk8s"
  }

}

output "ec2" {
    description = "Nginx domain name"
    value = aws_instance.microk8s.public_dns
}
