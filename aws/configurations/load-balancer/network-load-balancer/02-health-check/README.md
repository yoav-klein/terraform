# Health Checks
---

This builds on the previous example.

Here we configure a health check on the target group.
We use an application that has 2 ports: 5000 for the client traffic, and 8090 for health checks.

Also, we add a security group for the Network Load Balancer (new feature from mid 2023).

In order to allow traffic for the health check, we open the port 8090 on the servers security group
so from the security group associated with the NLB.

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
