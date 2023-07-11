

resource "aws_security_group" "server" {
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

resource "aws_key_pair" "this" {
  key_name   = "nginx-keypair"
  public_key = file("aws.pub")
}

resource "aws_instance" "nginx" {
  ami                  = "ami-053b0d53c279acc90" # Ubuntu 22.04
  key_name             = aws_key_pair.this.key_name
  instance_type        = "t2.small"
  vpc_security_group_ids = [ aws_security_group.server.id ]
  subnet_id = module.vpc.public_subnet_ids[0]
  user_data = <<EOF
#!/bin/bash
apt-get update
apt-get install -y nginx
echo "Hello from nginx" > /var/www/html/index.nginx-debian.html

EOF

  tags = {
    Name = "Nginx"
  }

}

output "server_domain" {
    description = "Nginx domain name"
    value = aws_instance.nginx.public_dns
}
