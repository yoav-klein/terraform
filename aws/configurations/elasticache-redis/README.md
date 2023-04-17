# ElastiCache for Redis
---

In this configuration we create an ElastiCache for Redis cluster.

This configuration creates the following resources:
* VPC
    * 3 private subnets
    * 1 public subnet
* EC2 instance, AMI ubuntu 22.04
* Redis cluster (or: replication group) with
    * 3 nodes: one primary and 2 replicas
    * A subnet group with several subnets
    * A separate parameter group with some parameter set
* Security groups: 1 for the EC2 instance, and 1 for the Redis cluster

## Usage
---
1. Create the resources with:
```
$ tf apply -auto-approve
```

2. Connect to the EC2 instance using SSH
3. Run
```
$ sudo apt-get update
$ sudo apt-get install redis
```

4. Connect to the Redis cluster:
```
$ redis-cli -h <redis_hostname_outputted_from_terraform>
```

5. Create and read a key:
```
redis> SET name yoav
redis> GET name
```

## Notes
---
When running in A Cloud Guru, you may not have permissions for the CreateReplicationGroup which is required
for this configuration. You can test it in your own AWS account.

