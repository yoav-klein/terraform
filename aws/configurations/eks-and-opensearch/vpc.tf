##########################################################
# Create a VPC

# the VPC contains 2 private subnets for the cluster
# and a public subnet for load balancers and whatever
##########################################################

module "vpc" {
  source   = "../../modules/vpc"
  name = "k8s-vpc"
  cidr     = "10.0.0.0/16"
  private_subnets = [{
        az   = "us-east-1b"
        cidr = "10.0.1.0/24"
    },
    {
      az   = "us-east-1c"
      cidr = "10.0.2.0/24"
    }]
  public_subnets = [{
    az   = "us-east-1a",
    cidr = "10.0.3.0/24"
  }]
}

resource "aws_eip" "this" {
    vpc = true
}


resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.allocation_id
  connectivity_type = "public"
  subnet_id         = module.vpc.public_subnet_ids[0]
}

resource "aws_route" "route_to_nat_gateway" {
    route_table_id = module.vpc.default_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this.id
}


