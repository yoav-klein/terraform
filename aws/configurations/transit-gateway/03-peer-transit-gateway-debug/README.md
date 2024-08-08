# Transit Gateway Peering
---

You can peer two or more transit gateways to allow flow of traffic between them.

In this example we create:
* 2 VPCs - each with a EC2 instance in the public subnet
    * In each - a route to the transit gateway
* 2 Transit Gateways, in each
    * A single route table
    * A VPC Attachment for the VPC that associates and propagates to the deafult route table
* A peering attachment that peers the 2 transit gateways
* A static route in each transit gateway to the peering attachment.


## Usage
---

Run the terraform code:
```
$ terraform apply -auto-approve
```

Distribute the keys:
```
$ ./distribute_keys.sh
```

SSH to VPC1 machine:
```
$ ssh -i private1.key ubuntu@<ip-of-vpc-1>
```

From there, SSH to VPC2 machine:
```
$ ssh -i private2.key ubuntu@<private-ip-of-vpc-2>
```

## BUG
---
For some reason, the routes in the VPC route tables that point to the transit gateway are
constantly deleted and recreated on each terraform run
