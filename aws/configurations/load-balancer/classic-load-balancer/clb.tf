

resource "aws_security_group" "load_balancer" {
    name = "LoadBalancer"
    vpc_id = module.vpc.vpc_id
    
    ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        description = "HTTP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
}

resource "aws_security_group_rule" "example" {
  type              = "egress"
  from_port         = 5000
  to_port           = 5000
  protocol          = "tcp"
  security_group_id = aws_security_group.load_balancer.id
  source_security_group_id = aws_security_group.servers.id
}

resource "aws_elb" "this" {
  name               = "MyLB"
    
  subnets = module.vpc.public_subnet_ids
  
  security_groups = [ aws_security_group.load_balancer.id  ]
  listener {
    instance_port     = 5000
    instance_protocol = "tcp"
    lb_port           = 80
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:5000/"
    interval            = 30
  }

  instances                   = module.ec2_servers.instance_ids
  cross_zone_load_balancing   = false
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "MyLB"
  }
}

output "elb_dns" {
    description = "DNS name of Load Balancer"
    value = aws_elb.this.dns_name
}
