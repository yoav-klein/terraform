# EKS and Self-Hosted Kubernetes
---

This builds on the `01-only-eks` example, with some changes and additions.

This demonstrates how to use IRSA with a self-hosted kubernetes cluster. 
Basically this follows the instructions in the https://github.com/aws/amazon-eks-pod-identity-webhook repo.

## How it works
---

First, some intro information:

Kubernetes, when you run a pod with a Service Account, generates a JWT 
for the pod (mounted in `/var/run/secrets/`). This JWT consists the following parts:
1. `iss` - the issuer of the JWT. In  a regular cluster this is `kubernetes.cluster.local` or something like this.
2. `aud` - the audience of the JWT. usually this is also as the issuer.
3. `sub` - `system:serviceaccount:<namespace>:<serviceaccount>`

Now, when you run kubernetes, you run it with the following flags:
`--service-account-key-file` - The public key to verify JWTs with. This is used by the API server
to validate JWTs that pods use to authenticate with.
`--service-account-signing-key-file` - The private key to sign JWTs that will be passed to the pods.
`-issuer-url` - the `iss` claim in the JWTs.

Now that you have the basis, what we do is the following: First , a RSA key pair is generated. These are placed in the `keys/` directory.
We place these somewhere on the k8s cluster machine, and point the above-mentioned flags to them.

Additionally, we create a S3 bucket in AWS to server as the discovery endpoint for our JWTs. Meaning, we place
there the `.well-known/openid-configuration` file, which points to the `jwks_uri`, which will also be in the same bucket.
The `jwks_uri` document contains the public key to validate JWTs with.

So currently we have a kubernetes cluster which will issue JWTs to pods that are signed 
with the private key that can be verified with the public key that's in our S3 bucket.

Now, we install the `amazon-eks-pod-identity-webhook`. What does this give us? This is a mutating webhook
that, whenever you run a pod with a service account that is annontated with a certain annotation (will be discussed below), 
will do inject the following environment variables to the pod:
```
AWS_ROLE_ARN=arn:aws:iam::434500956335:role/developer
AWS_WEB_IDENTITY_TOKEN_FILE=/var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

These env vars are picked up by the various AWS SDKs, and once deteceted, they are used to 
assume the specified role using the JWT pointed to by AWS_WEB_IDENTITY_TOKEN_FILE.

Since our JWT is signed with the correct private key, it will be verified and the assume request
will be completed.

Of course, we had to create an Identity Provider entity in AWS IAM and the URL of it
is the domain name of our S3 bucket.


## What this Terraform code includes
---

1. EKS cluster and node group, with all the necessary IAM policies, roles, etc.
2. Identity Provider for the EKS cluster
3. Identity Provider for the Microk8s (the self-hosted) cluster
4. S3 bucket for the content (for testing purposes)
5. S3 bucket for the OIDC configuration: `.well-known/openin-configruation` and `key.json`. This is a publicly accessible bucket.
6. A `developer` role for us to assume, with access to the content bucket.
7. EC2 instance which we host our Microk8s cluster in.

## Ansible code
--- 
The Ansible code in the `ansible` directory will:
1. Install Microk8s and the pod identity webhook deployment in it. 
2. Copy the public and private keys to the machine.
3. Modify the `kube-apiserver` arguments to point to those keys, and the `issuer-url` field
4. Restart the Microk8s cluster for the changes to take affect.
5. Copy the test pod YAML to the machine.


## Usage
---
1. Put the AWS credentials in the `enviroment` file and source it.
2. Run `gen_keys.sh` to create the keys.
3. `terraform apply -auto-approve` to run Terraform.
4. In order to run Ansible, we need the domain name of the OIDC S3 bucket. Run: 
```
ISSER_HOST=$(terraform output -raw s3_oidc_bucket_domain_name)
cd ansible;
ansible-playbook -i aws_ec2.yaml --key ../private.key -e issuer_host=$ISSUER_HOST playbook.yaml
```

5. Log in to the machine: `ssh -i private.key ubuntu@$(terraform output -raw ec2)`
6. Wait a minute or two for the webhook to take affect
7. Deploy the pod `kubectl apply -f pod.yaml`
8. Test to see it's working:
```
$ kubectl exec -it aws -- bash
$ aws sts get-caller-identity
# you should see yourself as 'developer' assumed role
$ aws s3 cp s3://<bucket_name>/content.txt -
IAM for Service Account Demo!
```


First, the changes:
1. Instead of creating the `content.txt` in the `setup.sh`, creating it in Terraform.


and adds a demonstration of using IRSA 
with a standalone, self-hosted Kubernetes cluster.


