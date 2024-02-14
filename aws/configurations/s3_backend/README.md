# S3 Backend
---

This demonstrates the use of a S3 bucket of a backend to store the state in.
Terraform will keep the `terraform.tfstate` file in the S3 bucket, rather
than in your local filesystem. This allows better security and enables collaboration
with other teammates.

## Prerequisites
---
1. Create a S3 bucket.
2. Put the name of the S3 bucket in the `main.tf` file.

The `key` field is the name of the S3 object to put the state in.
