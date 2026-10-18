# EC2 Instance Connect Endpoint
---

This configuration creates the following resources:
Networking:
* VPC
* 1 Private subnet
* EC2 Instance Connect Endpoint

EC2:
* EC2 instance in private subnet
* Security group for private instance
* Security group for the EC2 Instance Connect Endpoint
* Rules to allow SSH from the Instance Connect Endpoint to the private instance
