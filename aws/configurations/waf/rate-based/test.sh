#!/bin/bash

setup() {
    bucket_name=$(tf output -raw bucket_name)
    aws s3 cp index.html "s3://${bucket_name}/index.html" --acl="public-read"
}

test() {
    shopt -s expand_aliases
    
    cloudfront_url=$(tf output -raw cloudfront_url)
    i=0
    while true; do
        (( i = i+1 ))
        echo "Count: $(( i+1 ))"
        curl ${cloudfront_url}/index.html
        sleep 1
    done
}
