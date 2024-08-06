# Transit Gateway
---

A Transit Gateway allows you to connect two or more VPCs and allow communication between them.

In this example, we demonstrate how to connect 2 EC2 instances in separate VPCs using a Transit Gateway.

So we create 2 VPCs, with a EC2 instance in each of them. We create a transit gateway to connect them.

## Usage
---

Run terraform:
```
$ terraform apply -auto-approve
```

Copy the `private2.key` to the `vpc1` EC2:
```
$ scp -i private1.key ubuntu@$(terraform output -raw vpc1_ec2_public_domain):~
```

Note the private (!) domain name of `vpc2`:
```
$ terraform output -raw vpc2_ec2_private_domain
```

SSH into `vpc1` EC2:
```
$ ssh -i private1.key ubuntu@$(terraform output -raw vpc1_ec2_public_domain)
```

and in this machine, SSH to `vpc2` EC2:

```
$ ssh -i private2.key ubuntu@<vpc2-private-domain>
```
