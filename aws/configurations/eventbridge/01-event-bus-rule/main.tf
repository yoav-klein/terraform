terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.60"
        }
    }
}

provider "aws" {}



###########################################################
# 
#   The target Lambda function 
#
###########################################################

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


resource "aws_iam_role_policy_attachment" "execution_role" {
    role = aws_iam_role.iam_for_lambda.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "my_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

}


# resource-based policy to allow EventBridge to run the function

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.instance_change.arn
}

###########################################################
#
#   EventBridge
#
###########################################################

resource "aws_cloudwatch_event_rule" "instance_change" {
    name = "log-EC2-state-change"
    description = "Log EC2 state changes"
    
    event_pattern = jsonencode({
        source = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
        detail = { state = ["running", "stopping"] }
    
    })
}

resource "aws_cloudwatch_event_target" "yada" {
  rule      = aws_cloudwatch_event_rule.instance_change.name
  arn       = aws_lambda_function.test_lambda.arn
}
