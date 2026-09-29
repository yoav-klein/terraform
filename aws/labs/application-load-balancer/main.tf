
module "vpc" {
    source = "../../modules/vpc-v2"
    cidr = "10.0.0.0/16"
    public_subnets = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
    create_nat_gateway = true
    name = local.prefix
}

locals {
    prefix = "alb-lab"
}


##########################################################
# 
#   Target instances
#
##########################################################

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${local.prefix}-key-pair"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/my-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "targets" {
    count = 3

    ami = "ami-0b6d9d3d33ba97d99"
    instance_type = "t2.small"
    key_name = aws_key_pair.ssh.key_name
    subnet_id = module.vpc.private_subnets[count.index].id
    vpc_security_group_ids  = [aws_security_group.targets.id]

    tags = {
        Name = "${local.prefix}-target"
    }

    user_data = <<EOF
#!/bin/bash

curl -sSL get.docker.com | bash
docker run --network=host yoavklein3/health:0.1

EOF
    
    depends_on = [aws_vpc_security_group_egress_rule.targets_to_world]
}

resource "aws_security_group" "targets" {
    vpc_id = module.vpc.vpc_id
    name = "${local.prefix}-targets-sg"
    tags = {
        Name = "${local.prefix}-targets-sg"
    }
}


resource "aws_vpc_security_group_ingress_rule" "allows_app_from_lb" {
    security_group_id = aws_security_group.targets.id
    referenced_security_group_id = aws_security_group.load_balancer.id
    from_port         = 8080
    ip_protocol       = "tcp"
    to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "targets_to_world" {
    security_group_id = aws_security_group.targets.id
    cidr_ipv4         = "0.0.0.0/0"
    from_port         = 0
    ip_protocol       = "tcp"
    to_port           = 65535
}



##########################################################
#
#   Jump server
#
##########################################################

resource "aws_security_group" "jump_server" {
    vpc_id = module.vpc.vpc_id
    name = "${local.prefix}-jump-server-sg"
    tags = {
        Name = "${local.prefix}-jump-server-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_jump_server_from_world" {
    security_group_id = aws_security_group.jump_server.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "targets_from_jump_server" {
    security_group_id = aws_security_group.targets.id
    referenced_security_group_id = aws_security_group.jump_server.id
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "jump_server_to_targets" {
    security_group_id = aws_security_group.jump_server.id
    referenced_security_group_id = aws_security_group.targets.id
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
}

resource "aws_instance" "jump_server" {

    ami = "ami-0fef201115eefe936"
    instance_type = "t2.small"
    key_name = aws_key_pair.ssh.key_name
    subnet_id = module.vpc.public_subnets[0].id
    vpc_security_group_ids  = [aws_security_group.jump_server.id]

    tags = {
        Name = "${local.prefix}-target"
    }
}

output "target_private_dns" {
    value = aws_instance.targets[*].private_dns

}

output "jump_server_dns" {
    value = aws_instance.jump_server.public_dns
}



