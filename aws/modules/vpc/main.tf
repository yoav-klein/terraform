

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = ">= 4.51"
        }
    }
}

data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr
  enable_dns_hostnames = true # why not?
  tags = {
    Name = var.name
  }
}

###########################################
#
# Internet gateway created only when the user
# defines public subnets
#
###########################################

resource "aws_internet_gateway" "this" {
    count = length(var.public_subnets) > 0 ? 1 : 0
    
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.name}-igw"
    }
}

########################################
#
# A route table with a route
# to the Internet Gateway
# will be created only when the user
# defines public subnets
#
########################################

resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }
  tags = {
    Name = "${var.name}-public-rt"
  }
}


######################################
#
# A list of public subnets
# to be created in the VPC
#
######################################

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)
  vpc_id            = aws_vpc.this.id
  availability_zone = var.public_subnets[count.index].az
  cidr_block        = var.public_subnets[count.index].cidr
  map_public_ip_on_launch = var.auto_assign_public_ip
  tags = merge({
    Name = "${var.name}-pub-subnet-${count.index}"
  }, var.public_subnet_tags)
}

resource "aws_route_table_association" "publics" {
    count = length(var.public_subnets)
    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public[0].id
}

########################################
#
# A list of private subnets
# to be created in the VPC
#
########################################

resource "aws_eip" "this" {
    count = length(var.public_subnets) > 0 ? 1 : 0
}

# only if there are public subnets
resource "aws_nat_gateway" "this" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  
  connectivity_type = "public"
  allocation_id = aws_eip.this[0].id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "${var.name}-nat-gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.this]
}

# only if there are public subnets
resource "aws_route_table" "private" {
  count = length(var.public_subnets) > 0 ? 1 : 0
  
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this[0].id
  }
  tags = {
    Name = "${var.name}-private-rt"
  }
}


resource "aws_subnet" "private_subnets" {
    count = length(var.private_subnets)
    vpc_id = aws_vpc.this.id
    availability_zone = var.private_subnets[count.index].az
    cidr_block = var.private_subnets[count.index].cidr
    tags = merge({
        Name = "${var.name}-prvt-subnet-${count.index}"
    }, var.private_subnet_tags)
}

# if there aren't any public subnets, leave the private subnets with the main route table
resource "aws_route_table_association" "privates" {
    count = length(var.public_subnets) > 0 ? length(var.private_subnets) : 0
    subnet_id = aws_subnet.private_subnets[count.index].id
    route_table_id = aws_route_table.private[0].id
}


