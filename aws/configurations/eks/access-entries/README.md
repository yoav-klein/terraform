# Access Entries
---

Builds on the simple example.

This demonstrates the use of Access Entries and Access Policies.

We creatae a `john` user and create an access entry for him, and attach an access policy
that allows him to view the cluster.

## Usage
---

Apply terraform.

Then, export the AWS credentials of john:
```
$ export AWS_ACCESS_KEY_ID=<outputted access key id>
$ export AWS_SECRET_ACCESS_KEY=$(cat secret_access_key)
```

now, run `kubectl get po`. You should get a response which is not `forbidden`
