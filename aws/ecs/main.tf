

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

#######
# ECR
########

resource "aws_ecr_repository" "counter_service" {
  name                 = "counter-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}


#######
# ECS Cluster
######

resource "aws_ecs_cluster" "counter_service" {
  name = "my-cluster"
}

#########
# Task Definition
#########


# execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "role-name"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}



resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "counter_service" {
  family = "counter-service" # name
  execution_role_arn       = "arn:aws:iam::506189848464:role/ecsTaskExecutionRole"  # aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "counter-service"
      image     = "${aws_ecr_repository.counter_service.repository_url}:latest"
      cpu       = 1
      memory    = 1024
      essential = true
      
    },
  ])
  requires_compatibilities = ["FARGATE"]
  cpu = 1024
  memory = 2048
  network_mode = "awsvpc"
}

############
# ECS Service
#############

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

resource "aws_security_group" "task_sg" {
    name = "task_sg"
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


resource "aws_ecs_service" "counter_service" {
  name            = "counter_service"
  cluster         = aws_ecs_cluster.counter_service.id
  task_definition = aws_ecs_task_definition.counter_service.arn
  desired_count   = 1
  launch_type = "FARGATE"
#  load_balancer {
#    target_group_arn = aws_lb_target_group.foo.arn
#    container_name   = "mongo"
#    container_port   = 8080
#  }

  network_configuration {
    subnets = data.aws_subnets.all.ids
    security_groups = [aws_security_group.task_sg.id]

  }
}
