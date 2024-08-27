#!/bin/bash

setup() {
    bucket_name=$(terraform output -raw bucket_name)
    aws s3 cp index.html "s3://${bucket_name}/index.html" --acl="public-read"
}

test() {
    
    cloudfront_url=$(terraform output -raw cloudfront_url)
    curl ${cloudfront_url}/index.html
}
