# Artifactory server
---

This configuration creates the following resources:
* VPC infrastructure:
   * VPC
   * Private and public subnets
   * NAT Gateway
   * Internet Gateway
   * Routing tables
* EC2 instance in the public subnet


The EC2 instance runs an Artifactory server as a Docker container

## Usage
---

Apply the terraform code:
```
$ terraform apply -auto-approve
```

The Artifactory server listens on ports 8081 and 8082
