
# data sources to get VPC and subnets
data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "all" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

resource "aws_security_group" "lb_sg" {
    name = "lb_sg"
    # vpc - defaults to the deafult vpc
     
    ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    } 

}


resource "aws_security_group"

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = data.aws_vpc.default
  subnets            = data.aws_subnets.all
  security_groups    = aws_security_group.lb_sg

  access_logs = {
    bucket = "my-alb-logs"
  }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "IP"
    }
  ]


  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
