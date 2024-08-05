
resource "aws_ec2_transit_gateway" "this" {
  description = "example"
}


resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1" {
  subnet_ids         = module.vpc1.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.vpc1.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2" {
  subnet_ids         = module.vpc2.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.vpc2.vpc_id
}

resource "aws_route" "vpc1_to_tgw" {
    route_table_id = module.vpc1.public_route_table
    destination_cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.this.id
}

resource "aws_route" "vpc2_to_tgw" {
    route_table_id = module.vpc2.public_route_table
    destination_cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.this.id
}



