# Classic Load Balancer
---

This configuration demonstrates the use of Classic Load Balancer.

We create the following resources:
1. VPC with 2 public subnets and 2 private subnets
2. 2 EC2 instances in the private subnets, running our `echo` service using a Docker container
3. A security group for the EC2 instances:
* Ingress rule for port 5000 for the security group of the load balancer
4. A Classic Load Balancer for those instances
* A listener that listens on port 80, and forwards traffic to port 5000
* Enable the 2 public subnets
5. A security group for the load balancer with the following rules:
* Allow ingress on port 80 for everyone
* Allow egress on port 5000 to the security group of the instances
5. A bastion EC2 in the public subnet for debugging

## Usage
---

Run the configuration:
```
$ tf apply -auto-approve
```

Test:
```
$ curl <domain-name-of-nlb>
Hello <your_ip>, this is <ip_of_ec2>
```
