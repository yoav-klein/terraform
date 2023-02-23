

output "ec2_public_dns" {
    description = "EC2 public DNS"
    value = module.ec2.public_dns
}

output "lb_public_dns" {
    description = "Load Balancer DNS"
    value = module.alb.dns_name
}
