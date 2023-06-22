# RSA key for Encryption and Decryption
---

In this demo we demonstrate the usage of RSA keys to encrypt and decrypt messages.

We create a RSA key and an alias for it.

## Usage
1. Create the resources:
```
$ terraform apply -auto-approve
```

2. Sign and verify a message
```
$ aws kms sign --key-id alias/my-rsa-key-1 --signing-algorithm RSASSA_PSS_SHA_256 \
        --message fileb://plaintext.txt --output text --query Signature | base64 -d > signature
```

This will create the `signature` file, containing the signautre in binary form.

3. Verify the signature
```
$ aws kms verify --key-id alias/my-rsa-key-1 --signing-algorithm RSASSA_PSS_SHA_256 \
        --messsage file://signature --signature fileb://signature --query
```
