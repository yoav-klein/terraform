#!/bin/bash

if [ ! -f ~/.aws/credentials ] &&  ([ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_REGION" ]); then
    echo "export the AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_REGION variables"
    exit 1
fi

script_dir=$(cd -- "$(dirname -- ${BASH_SOURCE[0]})" > /dev/null && pwd)

command="$@"

[ -z "$command" ] && echo "Enter command" && exit 1

docker run -it -v ~/.aws:/root/.aws -v $script_dir:$script_dir \
    -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    -e AWS_REGION="$AWS_REGION" \
    -w $PWD  hashicorp/terraform:latest $command
