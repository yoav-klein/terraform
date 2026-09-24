
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "basics"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/my-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "private" {
    ami = "ami-0fef201115eefe936"
    instance_type = "t2.small"
    key_name = aws_key_pair.ssh.key_name
    subnet_id = aws_subnet.private.id
    vpc_security_group_ids  = [aws_security_group.private.id]

    tags = {
        Name = "basics-private"
    }

}

resource "aws_instance" "public" {
    ami = "ami-0fef201115eefe936"
    instance_type = "t2.small"
    key_name = aws_key_pair.ssh.key_name
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids  = [aws_security_group.public.id]
    
    tags = {
        Name = "basics-public"
    }
}

resource "aws_security_group" "public" {
    vpc_id = aws_vpc.main.id
    name = "basics-public"
    tags = {
        Name = "basics-public"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allows_ssh" {
    security_group_id = aws_security_group.public.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}


resource "aws_security_group" "private" {
    vpc_id = aws_vpc.main.id
    name = "basics-private"
    tags = {
        Name = "basics-private"
    }
}


resource "aws_vpc_security_group_ingress_rule" "allows_ssh_from_public" {
    security_group_id = aws_security_group.private.id
    referenced_security_group_id = aws_security_group.public.id
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allows_ssh_to_private" {
    security_group_id = aws_security_group.public.id
    referenced_security_group_id = aws_security_group.private.id
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}


output "public_ip" {
    value = aws_instance.public.public_ip
}
