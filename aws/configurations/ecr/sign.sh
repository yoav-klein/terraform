#!/bin/bash

KEY_ARN=$(terraform output -raw key_arn)
REPOSITORY_URL=$(terraform output -raw repository_url)

cosign sign --key awskms:///${KEY_ARN} ${REPOSITORY_URL}:0.1
