# EKS and OpenSearch
---

In this configuration we'll create an EKS cluster and an OpenSearch domain.

This is the required infrastructure for fluentd running as Kubernetes DaemonSet that sends logs to OpenSearch.

The following resources are created:
* VPC with
    * 1 public subnet
    * 2 private subnets
* Security groups
* EKS cluster
* Opensearch domain
* Windows EC2 to connect to Kibana

## Usage
---

### 1. Provision
```
$ terraform apply -auto-approve
```

### 2. Connect to OpenSearch Dashboards

The `terraform apply` will output:
* The domain name of the Windows machine.
* The domain name of OpenSearch Dashboards

Run the `./get-password.sh` script. This will create a `password` file.

Take the domain name and the password and connect using RDP to the machine. 
NOTE: make sure you connect using the `Administrator` user.

Then, take the domain name of OpenSearch Dashboards and browse to it.

