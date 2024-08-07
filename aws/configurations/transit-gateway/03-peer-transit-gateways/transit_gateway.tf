
resource "aws_ec2_transit_gateway" "one" {
  description = "example"
  tags = {
    Name = "one"
  }
}

resource "aws_ec2_transit_gateway" "two" {
  description = "example"
  tags = {
    Name = "two"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  subnet_ids         = module.vpc1.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.one.id
  vpc_id             = module.vpc1.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  subnet_ids         = module.vpc2.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.two.id
  vpc_id             = module.vpc2.vpc_id
}



resource "aws_route" "vpc1_to_tgw" {
    route_table_id = module.vpc1.public_route_table
    destination_cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.one.id
}

resource "aws_route" "vpc2_to_tgw" {
    route_table_id = module.vpc2.public_route_table
    destination_cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.two.id
}


data "aws_caller_identity" "current" {}

resource "aws_ec2_transit_gateway_peering_attachment" "peering" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "us-east-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.two.id
  transit_gateway_id      = aws_ec2_transit_gateway.one.id

  tags = {
    Name = "TGW Peering Requestor"
  }
}


data "aws_ec2_transit_gateway_peering_attachment" "peering" {
  
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.two.id]
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment.peering]
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "peering" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.peering.id

  tags = {
    Name = "Example cross-account attachment"
  }
}

resource "aws_ec2_transit_gateway_route" "one" {
  destination_cidr_block         = "10.0.0.0/8"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.one.association_default_route_table_id
}

resource "aws_ec2_transit_gateway_route" "two" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.two.association_default_route_table_id
}
