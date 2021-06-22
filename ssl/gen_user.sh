#!/usr/bin/env bash


if [ -z ${1+x} ]; then
    echo "Username parameter missing"
    return 1
fi

# Generate temp file name
echo "Generting temp file name"
username_hash="$(printf '%s' "$1" | sha256sum | cut -f1 -d' ')"
temp_file_name="$username_hash.cnf"

# Store client config to temp file
echo "Storing client config to temp"
cp client.cnf $temp_file_name
sed -i "s/<username_1>/$1/" $temp_file_name

# Generate client key
echo "Generating client key"
key_name="client.$1.key"
openssl genrsa -out certs/$key_name 4096

# Generate client csr
echo "Generating client csr"
csr_name="client.$1.csr"
openssl req \
-new \
-config $temp_file_name \
-key certs/$key_name \
-out csr/$csr_name \
-batch

# Sign the csr
echo "Signing client csr"
crt_name="client.$1.crt"
openssl ca \
-config ca.cnf \
-keyfile my-safe-directory/ca.key \
-cert certs/ca.crt \
-policy signing_policy \
-extensions signing_client_req \
-out certs/crt_name \
-outdir certs/ \
-in csr/$csr_name \
-batch

openssl x509 -in certs/crt_name -text | grep CN=

# Remove temp file
rm $temp_file_name