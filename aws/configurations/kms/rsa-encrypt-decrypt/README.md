# RSA key for Encryption and Decryption
---

In this demo we demonstrate the usage of RSA keys to encrypt and decrypt messages.

We create a RSA key and an alias for it.

## Usage
1. Create the resources:
```
$ terraform apply -auto-approve
```

2. Encrypt the plaintext message
```
$ aws kms encrypt --key-id alias/my-rsa-key --encryption-algorithm RSAES_AOEP_SHA_256 \
        --plaintext fileb://plaintext.txt --output text --query CiphertextBlob | base64 -d > blob
```

This will create the `blob` file, containing the encrypted message in binary form.

3. Decrypt the message
```
$ aws kms decrypt --key-id alias/my-rsa-key --encryption-algorithm RSAES_AOEP_SHA_256 \
        --ciphertext-blob file://blob --query Plaintext --output text | base64 -d
```
