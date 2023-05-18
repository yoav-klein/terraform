
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

module "vpc" {
    source = "../../../modules/vpc"
    name = "my_vpc"
    cidr = "10.0.0.0/16"
    public_subnets = [{ 
        az = "us-east-1b"
        cidr = "10.0.1.0/24"
    }, {
        az = "us-east-1a"
        cidr = "10.0.2.0/24"
    }, {
        az = "us-east-1c"
        cidr = "10.0.3.0/24"
    }]
}

locals {
    amis = {
        ubuntu = "ami-0f1bae6c3bedcc3b5"
    }
}

resource "aws_launch_template" "this" {
  name_prefix   = "foobar"
  image_id      = local.amis["ubuntu"]
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "this" {
  name = "my-auto-scaling-group"    

  desired_capacity   = 3
  max_size           = 5
  min_size           = 1
    
  vpc_zone_identifier = module.vpc.public_subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

