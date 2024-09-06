# Memory Consumption
---

This example demonstrates the memory-related metrics that are published to CloudWatch Insights.

We run a pod that consumes a fixed amount of memory. The `SIZE` variable determines the size of the `malloc`,
and the `PERCENT` variable determines how much of it will be actaully assigned with value.

The memory-related metrics are:
* `pod_memory_utilization` -  calculated as: `pod_memory_working_set / node_memory_limit`
* `pod_memory_utilization_over_pod_limit` - calculated as: `pod_memory_working_set / pod_memory_limit`
* `pod_memory_request` - The sum of the memory request of all the containers
* `pod_memory_limit`  - The sum of the memory limit set on all the containers
* `pod_memory_working_set` - the docs say that it's not reported directly as a metric, but I can see it in the list of metrics..


Here's a Log Insights Query that visualizes the `pod_memory_working_set`, `pod_memory_rss` and `pod_memory_limit`:
```
fields pod_memory_rss, pod_memory_working_set, pod_memory_limit |
filter Type = "Pod" | filter PodName = "memory-consumer" |
stats max(pod_memory_working_set), max(pod_memory_rss), max(pod_memory_limit) by bin(1min)
```
