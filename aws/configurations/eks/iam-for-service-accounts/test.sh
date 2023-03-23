#!/bin/bash

setup() {
    shopt -s expand_aliases
    source ../../../environment

    bucket_name=$(tf output -raw s3_bucket_name)
    account_id=$(aws sts get-caller-identity --query Account --output text)

    aws s3 cp content.txt s3://${bucket_name}/content.txt

    sed "s/<account_id>/$account_id/" pod.yaml | kubectl apply -f -
}

test() {
    bucket_name=$(tf output -raw s3_bucket_name)
    kubectl exec aws -- aws s3 cp s3://${bucket_name}/content.txt -
}
