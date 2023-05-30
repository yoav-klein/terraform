# VPC Endpoints
---

In this configuration, we demonstrate the use of VPC endpoints.

As a reminder, a VPC endpoint is a way for you to interact with AWS services
using a private IP address, as if they were in your VPC. So if for example you have
strict firewall rules, but you want to be able to communicate with AWS services, you can
create a VPC endpoint in your VPC and interact through it.

In this configuration we create an EC2 instance with no internet connectivity, and configure
a VPC endpoint for the Amazon RDS service, so that the EC2 instance can interact with it.

In this configuration, we create the following resource:
* VPC
    * 2 public subnets
    * 2 private subnets
* RDS cluster with 3 instances
* EC2 instances
    * Bastion host with internet connectivity
    * Private host, from which we want to interact with Amazon RDS.
    * NOTE: the private host has an Instance profile that allows it to access RDS resources.
* Required security groups


## Test
---
After provisioning the resources, SSH into the bastion machine:

```
$ ssh -i aws ubuntu@<public_dns>
```

Now, SSH to the private instance:
```
$ ssh -i aws ec2-user@<private_dns>
```

Now we want to test if we can interact with Amazon RDS. Run:
```
$ aws rds describe-db-instances 
```

You should get the list of the DB instances that we create here.

