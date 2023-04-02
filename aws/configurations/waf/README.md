# WAF
---

This configuration demonstrates the use of AWS WAF.

This configuration creates the following resources:
* S3 bucket
* CloudFront distribution which serves this bucket
* WAF web ACL
  * IP set

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

And you will see that you can't access the resource.

On the other hand, take the URL of the CloudFront distribution and try to access it
from another machine
