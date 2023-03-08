# Aurora MySQL
---

In this configuration, we create the following resources:
* VPC
* 3 private subnets
* 1 public subnet
* Aurora MySQL cluster
    * 3 instances
    * Subnet group
    * Security group that allows inbound for the EC2 security group
* EC2 instance to communicate with the cluster
    * Security group that allows outbound to the RDS security group

 
## Test
---
After provisioning the resources, SSH into the EC2 machine:

```
ssh -i aws ec2-user@<public_dns>
```

And run

```
$ mysql -h <cluster_endpoint> -u admin -p
```
