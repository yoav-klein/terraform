terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.60"
        }
    }
}

provider "aws" {}


resource "aws_iam_role" "execution_role" {
    name = "SchedulerExecutionRole"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
   })

}

resource "aws_iam_policy" "allow_ec2" {
  name        = "AllowEC2"
  path        = "/"
  description = "My test policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "allow_ec2" {
    role = aws_iam_role.execution_role.name
    policy_arn = aws_iam_policy.allow_ec2.arn
}

resource "aws_scheduler_schedule" "turn_on_ec2" {
  name       = "turn-on-ec2"

  schedule_expression = "rate(3 minutes)"
 
  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.execution_role.arn
    input = jsonencode({InstanceIds = [aws_instance.this.id]})
  }
}
