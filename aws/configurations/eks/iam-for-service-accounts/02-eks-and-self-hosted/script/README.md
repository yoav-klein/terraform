# Script
---

This go script will take the PKCS#8 public key we've created, and generate a
`keys.json` file ready to be deployed to the OIDC S3 bucket. This will 
be used by the relying party to validate JWTs.
