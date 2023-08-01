# Snapshots
---

This example builds on the `with-access-control` example.

This example contains configuration to create the necessary infrastructure to take snapshots
of the OpenSearch cluster.

We create the following additional resources:
* S3 bucket
* IAM Role
* IAM Policy that allows the necessary permissions to the bucket

The Role is assumed by OpenSearch in order to allow it to access the S3 bucket.

This is used in conjuction with the `snapshots.py` script in our `elasticsearch` repository in GitHub.

