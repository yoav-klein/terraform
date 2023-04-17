
resource "aws_security_group" "redis_sg" {
    name = "redis-sg"
    vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "ec2_sg" {
    name = "ec2-sg"
    vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ec2_redis" {
     type = "egress"
     description = "Allow Redis egress"
     from_port = local.port
     to_port = local.port
     protocol = "TCP"
     source_security_group_id = aws_security_group.redis_sg.id
     security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_security_group_rule" "rds_ec2" {
    type = "ingress"
    description = "Allow EC2 ingress"
    from_port = local.port
    to_port = local.port
    protocol = "TCP"
    source_security_group_id = aws_security_group.ec2_sg.id
    security_group_id = aws_security_group.redis_sg.id
}

