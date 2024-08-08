#!/bin/bash


vpc1_public=$(terraform output -raw vpc1_ec2_public_domain)
vpc2_public=$(terraform output -raw vpc2_ec2_public_domain)

vpc1_private=$(terraform output -raw vpc1_ec2_private_domain)
vpc2_private=$(terraform output -raw vpc2_ec2_private_domain)

echo "vpc1=$vpc1_private" > domains
echo "vpc2=$vpc2_private" >> domains

scp -i private1.key private2.key domains ubuntu@${vpc1_public}:~
scp -i private2.key private1.key domains ubuntu@${vpc2_public}:~
