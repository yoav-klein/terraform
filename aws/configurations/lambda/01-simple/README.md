# Simple
---

In this configuration we demonstrate a super-simple example of Lambda.

It's just a function that returns a little message.

Apply it, and then go to the _Test_ tab in the console to test it. 


NOTE that logs aren't sent from the Lambda function to CloudWatch Logs.
This is because our execution role has no permissions to do so.

We'll take care of this in the next section.
