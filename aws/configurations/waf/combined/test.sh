#!/bin/bash

setup() {
    bucket_name=$(tf output -raw bucket_name)
    aws s3 cp index.html "s3://${bucket_name}/index.html" --acl="public-read"
}

test() {
    shopt -s expand_aliases
    
    cloudfront_url=$(tf output -raw cloudfront_url)

    echo "Without the X-test: kuku header"
    curl ${cloudfront_url}/index.html

    echo "With the X-test: kuku header"
    curl -H "X-test: kuku" ${cloudfront_url}/index.html
}
