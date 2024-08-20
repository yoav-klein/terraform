# Autoscaling with Load Balancer
---

Builds on the first example.

Here we're adding an Application Load Balancer which will distribute traffic to our EC2 instances.

`min_elb_capacity` - waits for at least the specified number of instances are considered `Healthy` at the load balancer.


