
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${local.prefix}-KeyPair"
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
        Name = "${local.prefix}-instance"
    }

}

resource "aws_security_group" "private" {
    vpc_id = aws_vpc.main.id
    name = "${local.prefix}-instance-sg"
    tags = {
        Name = "${local.prefix}-instance-sg"
    }
}

# ice = Instance Connect Endpoint
resource "aws_security_group" "ice" {
    vpc_id = aws_vpc.main.id
    name = "basics-ice"
    tags = {
        Name = "${local.prefix}-ice"
    }
}


resource "aws_vpc_security_group_ingress_rule" "allows_ssh_from_ice" {
    security_group_id = aws_security_group.private.id
    referenced_security_group_id = aws_security_group.ice.id
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allows_ssh_to_private" {
    security_group_id = aws_security_group.ice.id
    referenced_security_group_id = aws_security_group.private.id
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
}


