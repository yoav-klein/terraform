#!/bin/bash

ip=$(terraform output -raw vpc1_ec2_public_domain)

ssh -i private1.key ubuntu@$ip
