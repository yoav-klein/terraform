# Karpenter
---

Built on the `aws-load-balancer-controller` example.

This configuration creates a EKS cluster with Karpenter installed.

## Technical details
---

### Terraform resources

In the `karpenter.tf` file, we create a IAM role for the Karpenter Controller

Also, we tag the private subnets with the `karpenter.sh/discovery: <cluster-name>` tag. We then
use this tag to tell Karpenter in which subnets to provision instances.

Also, we add outputs that we'll use in the installation of Karpenter and the deployment of NodePool and EC2NodeClass

### Installing Karpenter
In the `install_karpenter.sh` we install Karpenter using Helm.
Note that we need to set the `eks.amazonaws.com/role-arn` annotation on the `karpenter` serviceAccount to associate the service account with the Karpenter Controller role.

### Creating a NodePool and EC2NodeClass
In the `nodeclass.sh` we create a `NodePool` and a corresponding `EC2NodeClass`.
Note that in the EC2NodeClass resource we refer to the security group created by our cluster, so that new instances provisioned 
by Karpenter will be attached to this security group. This security group has all the necessary rules for communication in the cluster. 
