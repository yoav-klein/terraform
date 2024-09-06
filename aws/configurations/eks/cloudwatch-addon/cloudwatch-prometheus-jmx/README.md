# CloudWatch Agent with Prometheus support
---

https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-Prometheus.html

CloudWatch Cotnainer Insights container monitoring for Prometheus automates the discovery of Prometheus metrics
from containerized applications.

In order to enable this, we install the CloudWatch agent with Prometheus support. This is a Deployment in the cluster
that automatically discovers Prometheus metrics (using the `prometheus.yaml` configuration file; further read in our Prometheus document Google Docs)
and sends these metrics to CloudWatch (depending on the `cwagentconfig.json` configuartion file).

## JMX

In this example, we have a Java application that exports JMX metrics as Prometheus metrics.
We tweaked the configuartion file of the agent `cwagentconfig.json` so it sends some metrics that it doesn't send by deafult.
More specifically, I added the `jvm_memory_used_bytes`, `jvm_memory_max_bytes` and `jvm_memory_committed_bytes`:
```
{
                  "source_labels": ["job"],
                  "label_matcher": "^kubernetes-pod-jmx$",
                  "dimensions": [["ClusterName","Namespace","area"]],
                  "metric_selectors": [
                    "^jvm_memory_used_bytes$",
                    "^jvm_memory_max_bytes$",
                    "^jvm_memory_committed_bytes$"
                  ]
                },
```

These metrics help you monitor the JVM memory consumption status of your application.

## Usage
---

Run terraform apply
```
$ terraform apply -auto-approve
```

Then apply the demo application:
```
$ cd kubernetes-yamls
$ kubectl apply -f jmx-config.yaml
$ kubectl apply -f java-prom-exp.yaml
```

Go to CloudWatch metrics and look at the `ContainerInsights/Prometheus` namespace. There you can see these metrics.

NOTE: The `jvm_memory_max_bytes` is determined by the combination of the limits you set on the pod and the Java system variable: `-XX:MaxRAMPercentage`
which determines the max memory allowed as a percentage of the maximum memory that is available to the JVM.

