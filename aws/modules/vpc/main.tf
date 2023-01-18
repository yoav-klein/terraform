
data "aws_availability_zones" "available" {
	state = "available"
}

resource "aws_vpc" "vpc" {
	cidr_block = "10.0.0.0/16"
	tags = {
		Name = var.vpc_name
	}
}


resource "aws_subnet" "subnet" {
	count = length(data.aws_availability_zones.available.names)
	vpc_id = aws_vpc.vpc.id
	availability_zone = data.aws_availability_zones.available.names[count.index]
	cidr_block = "10.0.${count.index}.0/24"
}
