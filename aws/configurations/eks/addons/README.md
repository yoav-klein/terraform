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
This creates a PersistentVolumeClaim, which will dynamically provision a EBS volume in our AWS account.
Also, we create 2 pods which use this PersistentVolumeClaim: `write-app`, which writes to the volume,
and `read-pod` which reads from it.

```
$ kubectl apply -f demo/
```
wait a minute for the pods to run. Then, check if you see what's written by the `write-app` using the `read-app`:
```
$ kubectl exec read-app -- cat /data/out.txt
```

