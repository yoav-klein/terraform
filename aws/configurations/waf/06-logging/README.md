# Logging
---

In this configuration, we demonstrate logging in web ACL.

This configuration is based on the `two-rules` configuration.
This time, we add a logging configuration so that WAF will send
logs to CloudWatch Logs.


This configuration creates the following resources:
* S3 bucket
* CloudFront distribution which serves this bucket
* WAF web ACL with logging enabled
* A logging group in CloudWatch Logs

So we create a CloudFront disribution which serves the S3 bucket,
so we can access the bucket's contents using the distribution, and
we associate the web ACL with the CloudFront distribution.

NOTE that in Terraform, the logging configuration is a resource of its own.

## Usage
After creating the resources with `tf apply`, run:

```
$ . test.sh
$ setup
$ test
```

