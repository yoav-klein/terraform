#!/bin/bash

client_id=$(terraform output -raw client_instance_id)

aws ec2 get-password-data --instance-id $client_id --priv-launch-key generated-key.pem > client-password


server_id=$(terraform output -raw server_instance_id)

aws ec2 get-password-data --instance-id $server_id --priv-launch-key generated-key.pem > server-password
