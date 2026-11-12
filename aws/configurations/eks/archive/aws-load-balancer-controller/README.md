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


## Network Load Balancer

Apply the manifest in the `demo-nlb` directory:

```
$ kubectl apply -f demo-nlb/
```

This will create a Nginx Deployment and Service. Notice that the Service is annotated so that the AWS Load Balancer Controller
will pick it up.

Wait a few mins so that the Load Balancer will be Active, and then curl it:
```
$ curl $(kubectl get svc nginx-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

## Application Load Balancer
In order to create an Application Load Balancer, apply the manifest in the `demo-alb` directory:
```
$ kubectl apply -f demo-alb/
```

In this example, we create 2 services in our cluster: `number-generator` and `name-generator`. Our Ingress
will route traffic base on the HTTP path to each of the services.

### Some notes
* We use the `target-type: instance` in the `Ingress` resource. This will that 2 target groups with target type `Instance` will be created,
  which will route traffic to the nodes in the cluster. Each target group will contain all the nodes in the cluster, but
  will route to different ports - one for each NodePort of the 2 Services. When you use the `target-type: instance`, the backend
  services must be of type `NodePort`. 
  We could also use `target-type: ip`. In this case, the target groups would be of target type `IP`, and each target group would contain
  the list of IPs of the pods of the Services, so that traffic would be load balanced between the pods directly, without going through the Service in between.


## Technical Notes
* We create the `cert-manager` namespace before applying the full YAML of cert-manager. It seems that if you don't do this,
  sometimes there's a race condition and it applies the resources out-of-order.


