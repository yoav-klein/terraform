# Karpenter
---

Built on the `aws-load-balancer-controller` example.

This configuration creates a EKS cluster with Karpenter installed.

## Technical details
---

All the Karpenter related stuff is in the `karpenter.tf` file.
But there are also changes we've done in other resources to support Karpenter:
* Adding `karpenter.sh/discover:<cluster-name>` tag to the private subnets. This will be used to tell Karpenter in what subnets to deploy instances


### IAM

The Karpenter controller needs a bunch of permissions to create EC2 instances, terminate them, and more. So 
we create a role for the controller and a policy.

Note that the role assume policy allows the `karpenter` service account to assume the role.

### Karpenter installation

We use the Karpenter Helm chart in order to deploy Karpenter.
Note that we set the `serviceAccount.annotations` value with an IRSA annotation in order to associate the ServiceAccount used
 by Karpenter Controller to the role. 

### NodePool and EC2NodeClass

Finally, we deploy a NodePool and EC2NodeClass, which is essential for Karpenter to work.
Note that in the EC2NodeClass resource we refer to the security group created by our cluster, so that new instances provisioned 
by Karpenter will be attached to this security group. This security group has all the necessary rules for communication in the cluster. 

## Test
---

We have the `deployment.yaml` which is an Nginx deployment. Go ahead and deploy it.

Then, scale up to 7 replicas:
```
$ kubectl scale deploy --replicas=7 nginx
```

You'll see that Karpenter spin up a small node, as it only needs to deploy 1 pod on it (the rest fits on the single node of the cluster).
You can then scale up to 12 and see how it spins a bigger node, and then consolidates them.

