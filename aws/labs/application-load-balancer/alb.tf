
#####################################################
# 
#   Application Load Balancer
#
#####################################################

resource "aws_security_group" "load_balancer" {
    vpc_id = module.vpc.vpc_id
    name = "${local.prefix}-lb-sg"
    tags = {
        Name = "${local.prefix}-lb-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allows_lb_from_world" {
    security_group_id = aws_security_group.load_balancer.id
    cidr_ipv4   = "0.0.0.0/0"
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_lb_to_targets" {
    security_group_id = aws_security_group.load_balancer.id
    referenced_security_group_id = aws_security_group.targets.id
    from_port = 8080
    to_port = 8080
    ip_protocol = "tcp"
}

resource "aws_lb" "this" {
  name               = "${local.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = [for subnet in module.vpc.public_subnets : subnet.id]

  enable_deletion_protection = false

}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_v1.arn
  }
}


#####################################################
#
#   Target groups
#
#####################################################

resource "aws_lb_target_group" "app_v1" {
  name     = "${local.prefix}-app-v1"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
     path = "/health"
  }
}

resource "aws_lb_target_group_attachment" "example" {
  for_each = {
    for k, v in aws_instance.targets :
    k => v
  }

  target_group_arn = aws_lb_target_group.app_v1.arn
  target_id        = each.value.id
}

output "load_balancer_dns" {
    value = aws_lb.this.dns_name
}
