
resource "aws_ec2_transit_gateway" "vpc1" {
  description = "vpc1"

  tags = {
    Name = "VPC1"
  }
}

resource "aws_ec2_transit_gateway" "vpc2" {
  description = "vpc2"
  tags = {
    Name = "VPC2"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  subnet_ids         = module.vpc1.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.vpc1.id
  vpc_id             = module.vpc1.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  subnet_ids         = module.vpc2.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.vpc2.id
  vpc_id             = module.vpc2.vpc_id
}

resource "aws_route" "vpc1_to_tgw" {
    route_table_id = module.vpc1.public_route_table
    destination_cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.vpc1.id
}

resource "aws_route" "vpc2_to_tgw" {
    route_table_id = module.vpc2.public_route_table
    destination_cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.vpc2.id
}




##################################################################


data "aws_caller_identity" "current" {}

resource "aws_ec2_transit_gateway_peering_attachment" "peering" {
  peer_account_id         = data.aws_caller_identity.current.account_id
  peer_region             = "us-east-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.vpc2.id
  transit_gateway_id      = aws_ec2_transit_gateway.vpc1.id

  tags = {
    Name = "Peering requestor"
  }
}


data "aws_ec2_transit_gateway_peering_attachment" "peering" {

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.vpc2.id]
  }
  
  filter {
    name = "state"
    values = ["pendingAcceptance", "available"]
  }

  depends_on = [aws_ec2_transit_gateway_peering_attachment.peering]
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "peering" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.peering.id

  tags = {
    Name = "Peering acceptor"
  }
}

resource "time_sleep"  "wait_for_accepter" {
    depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.peering]

    create_duration = "30s"
}

resource "aws_ec2_transit_gateway_route" "one" {
  depends_on = [time_sleep.wait_for_accepter]

  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.vpc1.association_default_route_table_id
}

resource "aws_ec2_transit_gateway_route" "two" {
  depends_on = [time_sleep.wait_for_accepter]

  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.vpc2.association_default_route_table_id
}

