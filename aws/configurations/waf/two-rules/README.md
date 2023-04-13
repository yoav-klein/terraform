# Two rules
---

In this configuration, we demonstrate a web ACL with 2 rules configuration.

One rule filters based on IP address, and the other based on the header: `X-test: kuku`

This configuration creates the following resources:
* S3 bucket
* CloudFront distribution which serves this bucket
* WAF web ACL with the above rules

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
