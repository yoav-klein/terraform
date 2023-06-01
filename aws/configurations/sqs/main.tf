
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50"
    }
  }
}

provider "aws" { }

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_sqs_queue" "terraform_queue" {
  name                       = "example"
  delay_seconds              = 30
  visibility_timeout_seconds = 60
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 10 # long polling

  policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Current user allow all",
            "Effect": "Allow",
            "Principal": { "AWS": "${data.aws_caller_identity.current.arn}" },
            "Action": "sqs:*",
            "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:example"
        }
    ]
  }
POLICY

  tags = {
    Environment = "production"
  }
}


output "url" {
    description = "URL of the queue"
    value = aws_sqs_queue.terraform_queue.url
}

