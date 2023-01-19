

# - VPC
# - the user specifies a list of "public_subnets": { "cidr", "az" }
# - the user specifies a list of "private_subnets": {"cidr", "az"}
#
#


data "aws_availability_zones" "this" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block = var.cidr
  tags = {
    Name = var.vpc_name
  }
}

#####
# Internet gateway created only when the user
# defines public subnets

resource "aws_internet_gateway" "this" {
    count = length(var.public_subnets) > 0 ? 1 : 0
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.vpc_name}-igw"
    }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)
  vpc_id            = aws_vpc.this.id
  availability_zone = var.public_subnets[count.index].az
  cidr_block        = var.public_subnets[count.index].cidr
  tags = {
    Name = "${var.vpc_name}-pub-subent-${count.index}"
  }
}
