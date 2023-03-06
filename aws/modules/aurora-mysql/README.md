
# Aurora MySQL
---

A module for provisioning Aurora MySQL cluster

## Resources
---
These are the resource that will be created by this module

* Amazon Aurora DB cluster
* one or more DB instances
* subnet group
* security group

## Examples
---

See example usage [here](https://github.com/yoav-klein/terraform/tree/master/aws/test/aurora-mysql)

## Inputs
---

| Name | Type | Description |
| --- | --- | --- |
| name | `string` | Cluster identifier |
| instance_class  | `string` | default: `db.t3.small` |
| num_instances | `number` | Number of instances, including primary and replicas, default: 3 |
| port | `number` | Port number for connections, default: 3306 |
| publicly_accessible | `bool` | expose the instances publicly |
| username | `string` | Username for master user. default: `admin` |
| password | `string` | Password for master user |
| vpc_id | `string` | VPC ID to deploy the cluster in |
| subnet_ids | `list(string)` | List of subnet IDs to deploy the cluster in |

## Outputs
---

| Name | Type | Description |
| --- | --- | --- |
| cluster_endpoint | `string` | Cluster endpoint |
| reader_endpoint | `string` | Reader endpoint |
