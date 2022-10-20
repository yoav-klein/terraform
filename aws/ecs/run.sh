#!/bin/bash

source ../credentials.sh

command="$@"

[ -z "$command" ] && echo "Enter command" && exit 1

docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -v $PWD:/terraform -w /terraform hashicorp/terraform:latest $command

