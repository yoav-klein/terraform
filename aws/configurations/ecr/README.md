# Signing images
---

In this example, we:
1. Create a ECR repository
2. Push an image to it
3. Sign the image with a KMS key
4. Verify the signature

# Usage
---

```
# first, apply the Terraform configuration
$ terraform apply -auto-approve

# now, login to the repository
$ ./login.sh

# build and push the image
$ ./build_and_push.sh

# sign
$ ./sign.sh

# verify
$ ./verify.sh
```
