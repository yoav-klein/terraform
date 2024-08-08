# Transit Gateway - Multiple Route Tables
---

In this example we'll demonstrate network segmentation. We'll create:

1. 4 VPCs, each with a EC2 instance.
2. 1 Transit Gateway
3. 2 Route Tables
   * VPC1 and VPC2 associate and propagate to table 1
   * VPC3 and VPC4 associate and propagate to table 2
   * VPC1 propagates to table 2
   * VPC3 propagates to table 1

this means that:
1. VPC1 and VPC2 can communicate with each other
2. VPC3 and VPC4 can communicate with each other
3. VPC1 and VPC3 can communicate with each other
4. VPC2 can access VPC3, but not the other way
5. VPC4 can accsss VPC1, but not the other way




## Usage
---

Run terraform:
```
$ terraform apply -auto-approve
```

Copy all the keys to all the machines by running the `distribute_keys.sh` script.

Now SSH to `vpc1` machine, and from there try to:
* SSH to `vpc2` - you should succeed
* SSH to `vpc3` - you should succeed
* SSH to `vpc4` - you shouldn't succeed

Now SSH to `vpc3` machine, and run:
* SSH to `vpc4` - you should succeed
* SSH to `vpc1` - you should succeed
* SSH to `vpc2` - you shouldn't succeed

Now SSH to `vpc2` machine, and run:
* SSH to `vpc1` - you should succeed
* SSH to `vpc3` - you shouln't succeed

