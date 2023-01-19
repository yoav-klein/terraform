

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

