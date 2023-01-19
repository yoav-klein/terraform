
# VPC
---

A module which creates a VPC, along with some other resources.

## Resources
---

* VPC
* Private subnets (if `private_subnets` specified)
If `public_subnets` specified:
* Internet gateway
* Route table
* Public subnets associated with the route table

## Examples
---
[Simple example](https://github.com/yoav-klein/terraform/tree/main/aws/configurations/vpc_test)

## Inputs
---

| Name | Type | Description |
| --- | --- | --- |
| vpc_id | `string` | Name tag for the VPC |
| public_subnets | `list(object)` | List of public subnets, see below |
| private_subnets | `list(object)` | List of private subnets, see below |

### subnet object
Each subnet object in the `public_subnets` and `private_subnets` must have the following fields:
| Name | Type | Description |
| --- | --- | --- |
| az | `string` | Availability zone |
| cidr | `string` | CIDR block for the subnet |
| auto_assign_public_ip | `bool` | Whether or not to assign IP address for instance in the subnet |

## Outputs
---

| Name | Type | Description |
| --- | --- | --- |
| vpc_id | `string` | VPC ID |
| public_subnet_ids | `list(string)` | IDs of the public subnets |
| private_subnet_ids | `list(string` | IDs of the private subnets |


