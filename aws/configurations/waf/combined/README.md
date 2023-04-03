# WAF
---

In this configuration, we demonstrate a AND rule statement. This rule
combine 2 conditions: the IP address of this machine, and if 
the `X-test` header contains the value `kuku`


This configuration creates the following resources:
* S3 bucket
* CloudFront distribution which serves this bucket
* WAF web ACL

So we create a CloudFront disribution which serves the S3 bucket,
so we can access the bucket's contents using the distribution, and
we associate the web ACL with the CloudFront distribution.

The web ACL has one rule, which blocks traffic from the IP of this machine.

## Usage
After creating the resources with `tf apply`, run:

```
$ . test.sh
$ setup
$ test
```

The test function `curl`s the distribution once with the 
header and once without.
