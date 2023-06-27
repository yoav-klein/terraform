# With Access Control
---

This configuration creates a publicly-accessible OpenSearch domain
with resource-based access policy.

The policy allows the user that created the domain (which is the user you use to run
to run this configration) full access to the domain.

## Usage
---

1. Run the configuration:
```
$ terraform apply -auto-approve
```

2. Test the connection:
```
$ curl -u elastic:Yoav-Klein3 https://<endpoint>
```
