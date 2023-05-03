#/bin/bash

shopt -s expand_aliases

public_dns=$(tf output -json | jq -r '.public_dns.value[0]')
scp -i aws aws ubuntu@$public_ip:~
