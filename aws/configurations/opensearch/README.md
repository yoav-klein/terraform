
# OpenSearch
---

This folder contains several configuations for OpenSearch domains.

The `simple` folder contains a simple configuration.

The `with-access-policy` folder builds on top of the simple, and adds
a resource-based policy.


After deploying a domain, you can use the `elasticsearch` repository
to work against the domain.

Run
```
$ export ELASTIC_HOST=$(../../../run_tf.sh output -raw endpoint)
```

## Quickstart

The quickets and easiest way to start playing with Opensearch is using the 
`with-fgac` configuration. This will create a domain that is open to the world (not in a VPC)
 You use user and password to access it.

## elasticsearch submodule
The `elasticsearch` folder is a submodule which contains
some utility code for operating Elasticsearch clusters.



