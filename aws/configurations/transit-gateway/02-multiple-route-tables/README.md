# Transit Gateway - Multiple Route Tables
---

In this example we'll create 4 VPCs with a EC2 in each, and we'll associate 2 to 1 route table, and 2 to another route table.



## Usage
---

Run terraform:
```
$ terraform apply -auto-approve
```

Copy all the keys to all the machines by running the `distribute_keys.sh` script.

Now SSH to `vpc1` machine, and from there try to:
* SSH to `vpc2`
* SSH to `vpc3`

You'll see that you can SSH to `vpc2`, but not to `vpc3`. That's beacuse the attachments of `vpc1` and `vpc2` are
associated with one route table, and the attachments of `vpc3` and `vpc4` are assocaited with the other route table.

