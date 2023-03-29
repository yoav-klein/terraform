# CloudFront
---

This Terraform configuration creates a CloudFront distribution.
For this, we need an origin to route the traffic to.

So this configuration also creates an S3 Bucket which will host a file which we'll serve.

## Usage

1. Run the Terraform configuration.
```
$ tf apply -auto-approve
```

2. Upload the test file to S3
```
$ . test.sh
$ setup
```

3. Test
```
$ test
```
