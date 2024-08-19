
resource "aws_lb" "this" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnet_ids


  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "TCP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_target_group" "this" {
  name     = "my-tg"
  port     = 5000
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
  target_type = "instance"

  # health_check {

  #}
}

resource "aws_lb_target_group_attachment" "this" {
  count = 2

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = module.ec2_servers.instance_ids[count.index]
  #port            = 5000
}

output "nlb-domain-name" {
    description = "Domain name of the Network Load Balancer"
    value = aws_lb.this.dns_name
}
