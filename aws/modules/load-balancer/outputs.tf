output "target_group_arns" {
  value       = module.alb.target_group_arns
  description = "ARNs of target groups created"
}

output "dns_name" {
    description = "DNS name of load balancer"
    value = module.alb.lb_dns_name
}
