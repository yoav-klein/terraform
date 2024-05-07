# Network Load Balancer
---

This configuration demonstrates the use of Application Load Balancer.

We create the following resources:
1. VPC with 2 public subnets and 2 private subnets
2. 2 EC2 instances in the private subnets, running our `echo` service using a Docker container
3. A security group for the EC2 instances.
4. An Application Load Balancer for those instances
5. A bastion EC2 in the public subnet for debugging

## Usage
---

Run the configuration:
```
$ tf apply -auto-approve
```

Test:

NOTE: It may take some time until you'll get response from the servers. Give it a few minutes.

```
$ curl <domain-name-of-alb>
Hello <your_ip>, this is <ip_of_ec2>
```
