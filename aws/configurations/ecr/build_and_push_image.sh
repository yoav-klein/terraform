#!/bin/bash

REPOSITORY_URL=$(terraform output -raw repository_url)

docker pull nginx
docker tag nginx $REPOSITORY_URL:0.1

docker push $REPOSITORY_URL:0.1


