# Not publicly available
---

This configuration creates an OpenSearch domain which is deployed in a VPC.
It is not publicly available, but rather only from within the VPC.

This configuration creates the following resources:
* VPC with
    * 2 private subnets
    * 1 public subnet
* Security groups: one for the OpenSearch domain, and one for the EC2 instance.
* EC2 instance to connect to the domain from
* OpenSearch domain

## Usage
---

Run the terraform configuration:
```
$ tf apply -auto-approve
```

Connect to the EC2 instance:
```
$ ssh -i aws ec2-user@<ec2-domain-name>
```

Try to cURL to the domain:
```
$ curl https://<domain-endpoint>
```
