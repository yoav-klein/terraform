
output "instance_ids" {
    description = "ID of the instance"
    value = aws_instance.this.*.id
}
