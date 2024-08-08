
resource "aws_ec2_transit_gateway" "this" {
  description = "example"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    Name = "example"
  }
}

####################################
#
#  Transit Gateway Route Tables
#
###################################

resource "aws_ec2_transit_gateway_route_table" "vpc1_vpc2" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = {
    Name = "VPC1-VPC2"
  } 
}

resource "aws_ec2_transit_gateway_route_table" "vpc3_vpc4" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = {
    Name = "VPC3-VPC4"
  } 
}


####################################
#
#  Attachments
#
####################################

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

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc3" {
  subnet_ids         = module.vpc3.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.vpc3.vpc_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc4" {
  subnet_ids         = module.vpc4.public_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = module.vpc4.vpc_id
}


####################################
#
#  Subnet routes - routes in the subnets to the transit gateway
#
####################################


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


resource "aws_route" "vpc3_to_tgw" {
    route_table_id = module.vpc3.public_route_table
    destination_cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.this.id
}

resource "aws_route" "vpc4_to_tgw" {
    route_table_id = module.vpc4.public_route_table
    destination_cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.this.id
}

####################################
#
#  Route Table associations
#
####################################

resource "aws_ec2_transit_gateway_route_table_association" "vpc1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc1_vpc2.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc1_vpc2.id
}


resource "aws_ec2_transit_gateway_route_table_association" "vpc3" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc3_vpc4.id
}

resource "aws_ec2_transit_gateway_route_table_association" "vpc4" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc4.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc3_vpc4.id
}



####################################
#
#  Route Table propagations
#
####################################

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc1_rt1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc1_vpc2.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc2_rt1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc1_vpc2.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc3_rt2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc3_vpc4.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc4_rt2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc4.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc3_vpc4.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "vpc1_rt2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc3_vpc4.id
}


resource "aws_ec2_transit_gateway_route_table_propagation" "vpc3_rt1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc3.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.vpc1_vpc2.id
}



