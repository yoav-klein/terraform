#!/bin/bash

ACCESS_KEY_ID=AKIA6MHCIW6NTY45DWVF
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

output() {
    docker run -e AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$SECRET_KEY \
	-v $PWD:/terraform -w /terraform hashicorp/terraform:latest output
}

"$@"
