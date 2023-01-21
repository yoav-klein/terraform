

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
  tags = {
    Name = "${var.name}-pub-subnet-${count.index}"
  }
}

resource "aws_route_table_association" "publics" {
    count = length(var.public_subnets)
    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public.id
}

########################################
#
# A list of private subnets
# to be created in the VPC
#
########################################

resource "aws_subnet" "private_subnets" {
    count = length(var.private_subnets)
    vpc_id = aws_vpc.this.id
    availability_zone = var.private_subnets[count.index].az
    cidr_block = var.private_subnets[count.index].cidr
    tags = {
        Name = "${var.name}-prvt-subnet-${count.index}"
    }
}
