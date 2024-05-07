

locals {
    amis = {
        ubuntu = "ami-0f1bae6c3bedcc3b5"
    }
}


resource "aws_security_group" "servers" {
    name = "server-security-group"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        description = "SSH"
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

resource "aws_security_group" "load_balancer" {
    name = "load-balancer"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        description = "HTTP"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "TCP"
        description = "HTTPS"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_security_group_rule" "server_from_lb" {
  type              = "ingress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  source_security_group_id = aws_security_group.load_balancer.id
  security_group_id        = aws_security_group.servers.id
}

resource "aws_security_group_rule" "lb_to_server" {
  type              = "egress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  source_security_group_id = aws_security_group.servers.id
  security_group_id        = aws_security_group.load_balancer.id
}


resource "tls_private_key" "private_key" {
  algorithm   = "RSA"
}

resource "local_sensitive_file" "private_key" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "${path.module}/private.key"
}

resource "aws_key_pair" "key_pair" {
  key_name   = "jump-server-keypair1"
  public_key = tls_private_key.private_key.public_key_openssh

}



resource "aws_instance" "servers" {
  count = 2

  ami                  = local.amis["ubuntu"]
  key_name             = aws_key_pair.key_pair.key_name
  instance_type        = "t3.small"
  vpc_security_group_ids  = [aws_security_group.servers.id]
  subnet_id = module.vpc.private_subnet_ids[count.index % length(module.vpc.private_subnet_ids)]
  user_data = <<EOF
#!/bin/bash
curl -L get.docker.com | bash
docker run --network host yoavklein3/echo:0.1
EOF 


  tags = {
    Name = "server-${count.index}"
  }

}

resource "aws_instance" "bastion" {

  ami                  = local.amis["ubuntu"]
  key_name             = aws_key_pair.key_pair.key_name
  instance_type        = "t3.small"
  vpc_security_group_ids  = [aws_security_group.servers.id]
  subnet_id = module.vpc.public_subnet_ids[0]

  tags = {
    Name = "bastion"
  }

}


output "public_dns" {
    description = "public DNS of Bastion"
    value = aws_instance.bastion.public_dns

}
