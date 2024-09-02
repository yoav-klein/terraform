# Elastic Kubernetes Service
---

This builds on the `simple` example, and adds the CloudWatch Observability Add-on.
This add-on sends metrics and logs to Amazon CloudWatch.

See our document on it in Google Docs for more information.


## CloudWatch Agent with Prometheus Support
---
_Added in 2/9/2024_

CloudWatch agent with Prometheus support is a CloudWatch agent deployment which automates the discovery
of Prometheus metrics.
Here we have the `java-prom-exm` pod which runs a Java application with the Prometheus JMX Exporter which 
exposes Prometheus metrics. 

