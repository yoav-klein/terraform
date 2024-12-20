#!/bin/bash

setup() {
    account_id=$(aws sts get-caller-identity --query Account --output text)

    sed "s/<account_id>/$account_id/" pod.yaml.template > pod.yaml
    kubectl apply -f pod.yaml
}

test() {
    bucket_name=$(terraform output -raw s3_bucket_name)
    kubectl exec aws -- aws s3 cp s3://${bucket_name}/content.txt -
}
