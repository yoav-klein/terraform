
output "key_pair_name" {
   description = "Key pair name"
   value = aws_key_pair.this.key_name
}

output "instance_ids" {
    description = "ID of the instance"
    value = aws_instance.this.*.id
}

output "public_dns" {
    description = "Public DNS of the host"
    value = aws_instance.this.*.public_dns
}
