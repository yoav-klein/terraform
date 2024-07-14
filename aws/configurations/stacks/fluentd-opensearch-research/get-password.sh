#!/bin/bash

windows_id=$(terraform output -raw windows_instance_id)

aws ec2 get-password-data --instance-id $windows_id --priv-launch-key private.key > password

