

output "public_subnet_ids" {
    description = "IDs of public subnets"
    value = aws_subnet.public_subnets.*.id
}

output "private_subnet_ids" {
    description = "IDs of private subnets"
    value = aws_subnet.private_subnets.*.id
}

output "vpc_id" {
    description = "VPC ID"
    value = aws_vpc.this.id
}

output "default_route_table_id" {
    description = "Default route table ID"
    value = aws_vpc.this.default_route_table_id
}

output "public_route_table" {
    description = "Public route table"
    value = aws_route_table.public[0].id
}

output "private_route_table" {
    description = "Private route table"
    value = aws_route_table.private[0].id
}
