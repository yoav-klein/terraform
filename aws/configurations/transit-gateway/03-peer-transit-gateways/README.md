# Peer Transit Gateways
---

In this example we'll demonstrate how to connect 2 Transit Gateways using a peer attachment






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
