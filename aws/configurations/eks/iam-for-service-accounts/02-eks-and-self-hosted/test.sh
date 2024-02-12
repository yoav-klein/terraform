#!/bin/bash

test() {
    bucket_name=$(tf output -raw s3_bucket_name)
    kubectl exec aws -- aws s3 cp s3://${bucket_name}/content.txt -
}
