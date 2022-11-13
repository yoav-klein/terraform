#!/bin/bash

source ../credentials.sh
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

repository=$1
tag=$2

if [ -z "$repository" ] || [ -z "$tag" ]; then
    echo "Enter repository and tag"
    exit 1
fi

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $repository:$tag

docker tag counter-service:0.1 $repository:$tag
docker push $repository:$tag
