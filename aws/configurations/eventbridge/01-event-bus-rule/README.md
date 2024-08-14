# Event Bus rule
---

In this simple example, we'll create a rule in the default event bus which will run a Lambda Function
on each status change of a EC2 instance. 

The Lambda function just prints the event.

## Usage

Run the terraform code `terraform apply -auto-approve`

Then, start and stop the machine twice-three. Then go to the CloudWatch Logs stream of the Lambda Function
and you'll see the details of the event.

Something like:
```
{'version': '0', 'id': 'cf811bb8-94cc-49af-7334-ae342972813c', 'detail-type': 'EC2 Instance State-change Notification', 'source': 'aws.ec2', 'account': '891377391507', 'time': '2024-08-14T10:17:31Z', 'region': 'us-east-1', 'resources': ['arn:aws:ec2:us-east-1:891377391507:instance/i-05e39c6edc5d22667'], 'detail': {'instance-id': 'i-05e39c6edc5d22667', 'state': 'running'}}
```

