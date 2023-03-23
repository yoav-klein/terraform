# Elastic Kubernetes Service
---

This configuration creates the following infrastructure:
* VPC
  * 1 public subnet
  * 2 private subnets
  * NAT gateway in the public subnet
* EKS cluster
* EKS node group for the cluster


## Notes
---

* The EKS cluster has both private and public endpoints enabled
* The node group provisions nodes in the private subnets
* The NAT gateway is required for the nodes to be able to access the internet. This is required as per the [docs](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)


