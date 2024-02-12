# Elastic Kubernetes Service
---

This builds on the simple example, but this we deomnstrate the use of IAM for Service Accounts.

## Explanation
---
### IAM Identity providers background
In AWS IAM, we can configure a trust relationship between an external Identity provider and AWS account.
This can be either a OIDC or SAML provider.

Once you configure an OIDC provider, a user can access the AWS STS `AssumeRoleWithWebIdentity` API with an
ID token issued by the Identity provider.

### In EKS
A EKS cluster provides an OIDC provider, which grants ID tokens to Service Accounts.
All you need to do is annotate a service account with the role ARN that you want the pod to assume.


## Usage
---

### Run Terraform
Run the terraform code: `tf apply -auto-approve`

### Configure kubeconfig
```
$ ../configure_kubeconfig.sh
```

### Upload content to S3, and apply a pod
source the `test.sh` file, and run `setup`
```
$ source test.sh
$ setup
```

This uploads a file to the S3 bucket, and creates the pod with the ServiceAccount
who will have permissions to the bucket.

### Test
Wait a minute for the pod to start, and then
Run
```
$ test
```

This will have the pod accessing the S3 bucket.
