
resource "aws_security_group" "rds_ec2" {
    name = "rds-ec2"
    vpc_id = module.vpc.vpc_id
   }

resource "aws_security_group" "ec2_rds" {
    name = "ec2-rds"
    vpc_id = module.vpc.vpc_id
    
   }

resource "aws_security_group_rule" "ec2_rds" {
     type = "egress"
     description = "Allow RDS egress"
     from_port = local.port
     to_port = local.port
     protocol = "TCP"
     source_security_group_id = aws_security_group.rds_ec2.id
     security_group_id = aws_security_group.ec2_rds.id
}

resource "aws_security_group_rule" "rds_ec2" {

    type = "ingress"
    description = "Allow EC2 ingress"
    from_port = local.port
    to_port = local.port
    protocol = "TCP"
    source_security_group_id = aws_security_group.ec2_rds.id
    security_group_id = aws_security_group.rds_ec2.id
}

