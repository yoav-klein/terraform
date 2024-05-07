#!/bin/bash
private_key=demo.key
csr=demo.csr

# create private key and CSR
openssl genrsa -out $private_key 2048
openssl req -new -key $private_key -subj="/CN=yoav-klein.com" -out $csr -config req.conf -reqexts v3_req


# request a certificate from Let's Encrypt
sudo -E certbot certonly --dns-route53 -d yoav-klein.com --csr demo.csr
