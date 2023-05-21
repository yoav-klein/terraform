# EBS CSI Addon
---

Here we demonstrate the installation of the EBS CSI Addon to the EKS cluster.

The EBS CSI driver allows EKS to provision EBS volumes in AWS for `PersistentVolumes` objects.

Resources that we create:
* EKS cluster
* Managed node group
* IAM infrastructure for the cluster and node group
* IAM OIDC provider for the cluster
* IAM Role for the Service Account that will be used by the CSI driver
* EBS CSI Driver Addon

The Service Account that the CSI Driver uses allows it to provision EBS volumes in AWS.
This enables us to create PersistentVolumes in the cluster which provision EBS volumes in AWS.

## Demo application
The `demo` directory contains some resources to demonstrate the usage of the CSI driver.
It contains:
* A StorageClass that uses the driver as provisioner. This allows us to create PersistentVolumeClaims that will dynamically provision EBS volumes
* A PersistentVolumeClaim
* A pod that uses this PersistentVolumeClaim


## Usage
---

### Run Terraform
Run the terraform code: `tf apply -auto-approve`

### Configure kubeconfig
```
$ ../configure_kubeconfig.sh
```

### Run the demo application
```
$ kubectl apply -f demo/
```


This uploads a file to the S3 bucket, and creates the pod with the ServiceAccount
who will have permissions to the bucket.

### Test
Wait a minute for the pod to start, and then
Run
```
$ test
```

This will have the pod accessing the S3 bucket.
