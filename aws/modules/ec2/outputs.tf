
output "instance_ids" {
    description = "ID of the instance"
    value = aws_instance.ec2_instance.*.id
}
