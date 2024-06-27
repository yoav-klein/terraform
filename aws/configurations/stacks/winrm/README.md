# WinRM
---

This configuration provisions 2 Windows machines that you can use to experiment with WinRM.

One machine is to use as a server, and the other as a client (note that it doesn't really matter which is which; Heck, you don't even need two machines
if you work on a Windows machine - you can just use that as the client).


## Usage
First, run the terraform code:
```
$ terraform apply -auto-approve
```

Then, run the `get-password.sh` script to get the passwords of the two machines.

Then, using `terraform output` get the public domain name of the machine you want to connect to,
and connect using Remote Desktop Connection.  DON'T forget to login as `Administator` user
