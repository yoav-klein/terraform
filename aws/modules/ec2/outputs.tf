
output "instance_ids" {
    description = "ID of the instance"
    value = aws_instance.this.*.id
}

output "public_dns" {
    description = "Public DNS of the host"
    value = aws_instance.this.*.public_dns
}
