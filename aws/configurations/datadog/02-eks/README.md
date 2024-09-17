# Datadog + EKS
---

A EKS cluster with Datadog Operator installed.

## Usage
---

Apply terraform code:

```
$ terraform apply -auto-approve
```

Deploy the Datadog Operator:
```
$ ./configure_kubeconfig.sh
$ kubectl apply -f templates/datadog-operator.yaml
```
