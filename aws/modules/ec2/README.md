
# EC2
---

A module for provisioning EC2 instances

## Resources
---

* EC2 insatnce(s)
* Key pair
* Security group (optional)

## Examples
---

See example usage [here](https://github.com/yoav-klein/terraform/tree/main/aws/test/ec2)

## Inputs
---

| Name | Type | Description |
| --- | --- | --- |
| name | `string` | name of the EC2 instance(s) |
| instance_type | `string` | e.g. t2.small | 
| instance_count | `number` | number of instaces |
| pub_key_path | `string` | Path of public key to associate with the instance(s) |
| default_vpc | `bool` | Whether or not to deploy the instance to the default VPC |
| vpc_id | `string` | VPC ID to provision the instances in. Irrelevant if default_vpc is true | 
| subnet_ids | `list(string)` | IDs of subnets to provision the instance(s) in. Irrelevant if default_vpc is true |
| default_sg | `bool` | Whether or not to create a security group with some common rules for the instances |
| security_group_ids | `list(string)` | Security groups to associate with the instace. |

## Outputs
---

| Name | Type | Description |
| --- | --- | --- |
| instance_ids | `list(string)` | List of instnace IDs |


