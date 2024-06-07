# Webapp on EKS
---

In this configuration we have a basis for a web application hosted on EKS.

## What's included
---
The configration creates a:

* EKS cluster (with the node group, IAM infra and all..)
    * With AWS Load Balancer Controller which takes Ingress objects and makes a Application Load Balancer from them
* A Certificate from Let's Encrypt
* Route53 records to point `yoav-klein.com` to the application
* Kubernetes objects:
    * Ingress (which creates the Application Load Balancer)
    * Deployments and Services (`names` and `numbers`)

## Prerequisites
We have a domain `yoav-klein.com` at GoDaddy. But we need to change the nameservers to Route 53:

1. Go to the `route53` directory, create a public Hosted Zone. This will output a list of nameservers.
2. Go to GoDaddy and change the nameservers to these nameservers of Route 53.

Only now we can run certbot to issue a certificate for our site.


## Usage
---

1. Run the `get_manifests.sh` script to get the AWS Load Balancer Controller manifests to be installed
2. Run the `certificate.sh` script. This will: 
a. Create a private key and a CSR
b. Use certbot to issue a certificate and a certificate chain.
3. Create a certificate chain file by chaining all the `chain_0000.pem`, `chain_0001.pem`, etc. files: `cat 0000_chain.pem .. > chain.pem`
4. Run `terraform apply`

## Test
---

Run
```
$ curl https://www2.yoav-klein.com/name
```
or
```
$ curl https://wwww2.yoav-klein.com/number
```

If you try accessing port 80, you'll be redirected to 443:
```
$ curl http:/www2.yoav-klein.com/number
301 Moved
```

## Explanation
---

Due to the AWS Load Balancer Controller (LBC), the Ingress object will create an Application Load Balancer
We use the tags that are created on this ALB by the LBC to get the domain name of this ALB.
We then use this in the Route53 A record to point `www2.yoav-klein.com` to the ALB.

Additionally, we use an annotation to attach the ALB to our Certificate.
