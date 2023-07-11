# Nginx
---

This configuration creates the following resources:
* VPC infrastructure:
   * VPC
   * Private and public subnets
   * NAT Gateway
   * Internet Gateway
   * Routing tables
* EC2 instance in the public subnet


The EC2 instance runs a Nginx server

## Usage
---

Apply the terraform code:
```
$ terraform apply -auto-approve
```

Test:
```
$ curl <server_domain_name>
```
