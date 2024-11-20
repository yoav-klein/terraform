# IRSA - Micro-services Scenario
---

This project is based on `01-only-eks` project.

The idea is to simulate a situation where we have a cluster with many services, and we want a different set of permissions for each service.
So each service runs with its own service account, therefore a different Role.

So we have the `irsa` module which creates:
* A role
* Trust policy that allows a list of service accounts to assume the role
* A list of policies to attach to the role.

All this is passed to the module as variables, which allows for maximum flexibility.
