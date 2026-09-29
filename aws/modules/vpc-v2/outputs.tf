

output "public_subnets" {
    description = "IDs of public subnets"
    value = aws_subnet.public_subnets.*
}

output "private_subnets" {
    description = "IDs of private subnets"
    value = aws_subnet.private_subnets
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
    value = try(aws_route_table.public[0].id, null)
}

output "private_route_table" {
    description = "Private route table"
    value = try(aws_route_table.private[0].id, null)
}
