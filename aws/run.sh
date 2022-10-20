#!/bin/bash

ACCESS_KEY_ID=AKIAREHHM4R7EQKA6X6C
SECRET_KEY=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

apply() {
    docker run -e AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$SECRET_KEY \
	-v $PWD:/terraform -w /terraform hashicorp/terraform:latest apply -auto-approve
}	

destroy() {
    docker run -e AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$SECRET_KEY \
	-v $PWD:/terraform -w /terraform hashicorp/terraform:latest destroy -auto-approve
}

show() {
    docker run -e AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$SECRET_KEY \
	-v $PWD:/terraform -w /terraform hashicorp/terraform:latest show
}

"$@"
