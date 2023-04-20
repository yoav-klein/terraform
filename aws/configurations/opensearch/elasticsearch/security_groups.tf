
resource "aws_security_group" "ec2" {
    name = "ec2"
    vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "opensearch" {
    name = "opensearch"
    vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "ec2" {
     type = "egress"
     description = "Allow egress to OpenSearch"
     from_port = 443
     to_port = 443
     protocol = "TCP"
     source_security_group_id = aws_security_group.opensearch.id
     security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "opensearch" {
    type = "ingress"
    description = "Allow EC2 ingress"
    from_port = 443
    to_port = 443
    protocol = "TCP"
    source_security_group_id = aws_security_group.ec2.id
    security_group_id = aws_security_group.opensearch.id
}


