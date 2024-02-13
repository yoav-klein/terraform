
rm -rf keys
mkdir -p keys

# Generate the keypair
PRIV_KEY="keys/sa-signer.key"
PUB_KEY="keys/sa-signer.key.pub"
PKCS_KEY="keys/sa-signer-pkcs8.pub"
# Generate a key pair
ssh-keygen -t rsa -b 2048 -f $PRIV_KEY -m pem
# convert the SSH pubkey to PKCS8
ssh-keygen -e -m PKCS8 -f $PUB_KEY > $PKCS_KEY
