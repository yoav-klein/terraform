

resource "aws_security_group" "endpoint" {
    name = "VPCendpoint"
    vpc_id = module.vpc.vpc_id

    ingress {
        description = "Ingress to RDS"
        from_port = 443
        to_port = 443
        protocol = "TCP"
        security_groups = [aws_security_group.private.id]
    }
}

# resource endpoint
