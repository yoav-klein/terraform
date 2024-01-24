# fluentd
---

This Kubernetes configuration creates a fluentd DaemonSet in the EKS cluster which will
publish logs to OpenSearch. It's suitable for running in the EKS + AWS OpenSearch environment.

It's designed to work with an OpenSearch domain that has no access control, so the user password
is null.

All you need to change is the host key in the `fluentd-ds.yaml` file
