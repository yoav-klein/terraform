
resource "aws_lb" "this" {
  name               = "my-lb-1"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnet_ids
  security_groups    = [aws_security_group.load_balancer.id]

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}




resource "aws_lb_target_group" "this" {
  name        = "my-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  # health_check {

  #}
}

resource "aws_lb_target_group_attachment" "this" {
  count = 2

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.servers[count.index].id
  #port            = 5000
}

output "alb-domain-name" {
  description = "Domain name of the Network Load Balancer"
  value       = aws_lb.this.dns_name
}
