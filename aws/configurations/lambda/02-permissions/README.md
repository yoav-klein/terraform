# Permissions
---

All we've added in this configuration is: we've attached an IAM policy to the execution
role, so that our function can create a Log Group in CloudWatch Logs and publish log 
records to it.

After applying and running this, you'll see that there's a log group in CloudWatch Logs
for our function, and that invocations are recorded there.
