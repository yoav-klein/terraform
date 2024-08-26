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

SSH into the machine and run the `run.sh` script.
Wait for a few minutes for Artifactory to run.

Then you can browse to it using the URL:
```
http://<domain-name>:8081
```

The initial credentials are `admin:password`
