# AWS Load Balancer Controller
---

In this configuration we install the AWS Load Balancer Controller in the EKS cluster.

The AWS Load Balancer Controller is a controller deployed in the EKS cluster which enables it
to create Network Load Balancer and Application Load Balancers in AWS.

Network Load Balancers are created for `Service` objects of type `LoadBalancer`
Application Load Balancers are created for `Ingress` objects.

## Resources created

The regular resources are:

* EKS cluster
* EKS managed node group
* IAM OIDC provider for the EKS cluster
* Required IAM infrastructure

The additional resources for the AWS Load Balancer Controller are:
* IAM Policy for the AWS Load Balancer Controller
* IAM Role for this policy

This Role will be assumed by the AWS Load Balancer Controller pods using a ServiceAccount.

The kubernetes manifests that we apply:
* cert-manager
* AWS Load Balancer Controller
* IngressClass

We get those YAMLs using the `get_manifests.sh` script.

## Using the kubectl Provider

In this configuration, we use the `kubectl` Terraform provider. This provider provides the
`kubectl_manifest` resource, and the `kubectl_file_documents` data resource.

Take a look at the `providers.tf` file to see how we configure this provider so it can access the cluster that we create.


## Usage
---

### Run Terraform
First, generate the required YAML manifests using the `get_manifests.sh` script:
```
$ ./get_manifests.sh
```
Run the terraform code: `tf apply -auto-approve`

### Configure kubeconfig
```
$ ../configure_kubeconfig.sh
```

### Test
Wait a minute for the pod to start, and then
Run
```
$ test
```

## Technical Notes
* We create the `cert-manager` namespace before applying the full YAML of cert-manager. It seems that if you don't do this,
  sometimes there's a race condition and it applies the resources out-of-order.

