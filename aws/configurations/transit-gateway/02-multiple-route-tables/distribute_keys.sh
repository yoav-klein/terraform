#!/bin/bash


vpc1_public=$(terraform output -raw vpc1_ec2_public_domain)
vpc2_public=$(terraform output -raw vpc2_ec2_public_domain)
vpc3_public=$(terraform output -raw vpc3_ec2_public_domain)
vpc4_public=$(terraform output -raw vpc4_ec2_public_domain)

for i in 1 2 3 4; do
    public_ip=vpc${i}_public
    key=private${i}.key
    echo "== Copying keys to ${!public_ip}, using ${key}"
    for j in 1 2 3 4; do
        copy_key=private${j}.key
        scp -i ${key} ${copy_key} ubuntu@${!public_ip}:~
    done
done
