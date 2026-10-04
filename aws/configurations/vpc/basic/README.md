# Simple
---

This configuration creates the following resources:
Networking:
* VPC
* 1 Public subnet
* 1 Private subnet
* Internet gateway
* Route table for public subnet that routes 0.0.0.0/0 to Internet Gateway

EC2:
* EC2 instance in public subnet
* EC2 instance in private subnet
* Security group for private instance
* Security group for public instance
* Rule to allow SSH traffic to public instance from world
* Rule to allow SSH traffic from public to private  
