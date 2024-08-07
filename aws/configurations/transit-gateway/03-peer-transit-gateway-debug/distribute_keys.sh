#!/bin/bash


vpc1_public=$(terraform output -raw vpc1_ec2_public_domain)
vpc2_public=$(terraform output -raw vpc2_ec2_public_domain)

scp -i private1.key private2.key ubuntu@${vpc1_public}:~
scp -i private2.key private1.key ubuntu@${vpc2_public}:~

