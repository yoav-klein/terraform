
resource "aws_security_group" "redis_ec2" {
    name = "redis-ec2"
    vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "ec2_redis" {
    name = "ec2-redis"
    vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ec2_redis" {
     type = "egress"
     description = "Allow Redis egress"
     from_port = local.port
     to_port = local.port
     protocol = "TCP"
     source_security_group_id = aws_security_group.redis_ec2.id
     security_group_id = aws_security_group.ec2_redis.id
}

resource "aws_security_group_rule" "rds_ec2" {
    type = "ingress"
    description = "Allow EC2 ingress"
    from_port = local.port
    to_port = local.port
    protocol = "TCP"
    source_security_group_id = aws_security_group.ec2_redis.id
    security_group_id = aws_security_group.redis_ec2.id
}

