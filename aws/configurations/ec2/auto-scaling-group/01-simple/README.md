# Autoscaling Groups
---

This is a simple example of Autoscaling Groups.

We create an Autoscaling group which runs 3 instances of EC2. Each instance runs our `echo` server/

## Usage
---

Run the terraform code.
```
$ terraform apply -auto-approve
```

Then, take the public IP of one of the machines and run:
```
$ curl <ip>:5000
```

