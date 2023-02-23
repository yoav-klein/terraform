#!/bin/bash

#
#   this script demonstrates how to call AWS API using curl
#   and sign the requests with AWS Signature Version 4
#


AWS_ACCESS_KEY_ID=AKIARDVWCQ3XMBGGIPNX
AWS_SECRET_ACCESS_KEY=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
domain_url="https://$(../../../run_tf.sh output -raw endpoint)"

check() {
    request_uri="$domain_url/_cluster/health"
    curl --aws-sigv4 "aws:amz:us-east-1:es" -XGET -u $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY "$request_uri"
}

create_index() {
    request_uri="$domain_url/myindex"
    curl --aws-sigv4 "aws:amz:us-east-1:es" -XPUT -u $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY "$request_uri"
}

cat_shards() {
    request_uri="$domain_url/_cat/shards"
    curl --aws-sigv4 "aws:amz:us-east-1:es" -XGET -u $AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY "$request_uri"
}

cat_shards
#create_index
