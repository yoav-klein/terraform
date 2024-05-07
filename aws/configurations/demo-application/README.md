# Website
---


This configuration creates a set of resources that form a basic skeleton of a website.

## What's included
---
This configuration creates a:
* DNS record for `www.yoav-klein.com` which will bring the user to our site
* A certificate from Let's Encrypt, which will be used by our site.
* Two web servers that respons to requests
* An Application Load Balancer

This configuration demonstrates the use of:

AWS:
* Route53
* Application Load Balancer
* AWS Certificate Manager

And:
* cerbot


## Prerequisites
---

We have a domain `yoav-klein.com` at GoDaddy. But we need to change the nameservers to Route 53:
1. Go to the `route53` directory, create a public Hosted Zone. This will output a list of nameservers.
2. Go to GoDaddy and change the nameservers to these nameservers of Route 53.

Only now we can run certbot to issue a certificate for our site.


## Usage
---

1. Run the `certificate.sh` script. This will: 
a. Create a private key and a CSR
b. Use certbot to issue a certificate and a certificate chain.
2. Create a certificate chain file by chaining all the `chain_0000.pem`, `chain_0001.pem`, etc. files: `cat 0000_chain.pem .. > chain.pem`
3. Run `terraform apply`

## Test
---

Run 
```
curl https://$(terraform output -raw website_url)
```
