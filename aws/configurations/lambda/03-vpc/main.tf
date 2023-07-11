terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.50"
        }
    }
}

provider "aws" {}


#############################################
# Lambda
#############################################

    
resource "aws_security_group" "lambda_to_ec2" {
  name = "LambdaToEC2"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    security_groups  = [aws_security_group.server.id]
    ipv6_cidr_blocks = ["::/0"]
  }
}



data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "basic" {
    role = aws_iam_role.iam_for_lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc" {
    role = aws_iam_role.iam_for_lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "test_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.root}/deployment_package/deployment_package.zip"
  function_name = "my_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.handler"

  #source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  environment {
    variables = {
      foo = "bar"
    }
  }

  vpc_config {
    subnet_ids = module.vpc.private_subnet_ids
    security_group_ids = [ aws_security_group.lambda_to_ec2.id ]
  }
}
