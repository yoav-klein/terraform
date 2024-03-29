# VPC
---

In this configuration, we're enabling our Lambda function to access resources wihtin our VPC.

For this, we'll create the following resources:
* A VPC infrastructure with a private and public subnet
* An EC2 instance which runs some web application

We'll configure our Lambda function to make an HTTP request to our application, and return the response.

NOTES:
1. We need to attach another policy to the execution role, so that the function can create 
ENIs in our VPC.

## Usage
---

First, create the deployment package:
```
$ cd deployment_package
$ ./create_package.sh
```

Then, apply the terraform configuration:
```
$ terraform apply -auto-approve
```

Now, go to the console and run a Test. You should get `hello from nginx`.
