
rm -rf keys
mkdir -p keys

# Generate the keypair
PRIV_KEY="$PWD/keys/oidc-issuer.key"
PUB_KEY="$PWD/keys/oidc-issuer.key.pub"
PKCS_KEY="$PWD/keys/oidc-issuer.pub"
# Generate a key pair
ssh-keygen -t rsa -b 2048 -f $PRIV_KEY -m pem
# convert the SSH pubkey to PKCS8
ssh-keygen -e -m PKCS8 -f $PUB_KEY > $PKCS_KEY

cd script
go get
go run ./main.go -key $PKCS_KEY | jq '.keys += [.keys[0]] | .keys[1].kid = ""' > ../files/keys.json
