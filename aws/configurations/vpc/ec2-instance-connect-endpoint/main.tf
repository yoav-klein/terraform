
locals {
    prefix = "ice"
}   


resource "aws_vpc" "main" {
    tags = {
        Name = local.prefix
    }
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true # default is false
    enable_dns_support = true # default is true
}

resource "aws_subnet" "private" {
    vpc_id  = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"

    tags = {
        Name = "${local.prefix}-PrivateSubnet"
    }
}

resource "aws_ec2_instance_connect_endpoint" "example" {
    subnet_id = aws_subnet.private.id
    security_group_ids = [aws_security_group.ice.id]
}

