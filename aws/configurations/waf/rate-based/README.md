# WAF
---

In this configuration, we demonstrate the rate-based rule.

This configuration creates the following resources:
* S3 bucket
* CloudFront distribution which serves this bucket
* WAF web ACL with a rate-based rule

The rate-based rule limits the number of requests received from an IP address
to 100. In our test, we'll `curl` the endpoint each second, until we hit the limit
and get an error.

## Usage
After creating the resources with `tf apply`, run:

```
$ . test.sh
$ setup
$ test
```

