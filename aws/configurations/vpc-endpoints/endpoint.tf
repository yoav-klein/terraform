
data "aws_region" "current" {}

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

resource "aws_vpc_endpoint" "this" {
    vpc_id = module.vpc.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.rds"
    ip_address_type = "ipv4"
    subnet_ids = module.vpc.private_subnet_ids
    vpc_endpoint_type = "Interface"
    security_group_ids = [aws_security_group.endpoint.id]
    private_dns_enabled = true    

    tags = {
        Name = "RDS_Endpoint"
    }
}
