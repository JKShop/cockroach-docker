#!/usr/bin/env bash

if [ -z ${1+x} ]; then
    echo "DNS parameter missing"
    return 1
fi


if [ -z ${2+x} ]; then
    echo "External IP parameter missing"
    return 1
fi

# Generate temp file name
echo "Generting temp file name"
dns_ip_hash="$(printf '%s' "$1$2" | sha256sum | cut -f1 -d' ')"
temp_file_name="$dns_ip_hash.cnf"

# Store node config to temp file
echo "Storing node config to temp"
cp node.cnf $temp_file_name
sed -i "s/<node-domain>/$1/" $temp_file_name
sed -i "s/<IP Address>/$2/" $temp_file_name

# Generate node key
echo "Generating node key"
key_name="$1.key"
openssl genrsa -out certs/$key_name 4096

# Generate node csr
echo "Generating node csr"
csr_name="$1.csr"
openssl req \
-new \
-config $temp_file_name \
-key certs/$key_name \
-out csr/$csr_name \
-batch

# Sign the csr
echo "Signing node csr"
crt_name="$1.crt"
openssl ca \
-config ca.cnf \
-keyfile my-safe-directory/ca.key \
-cert certs/ca.crt \
-policy signing_policy \
-extensions signing_node_req \
-out certs/$1.crt \
-outdir certs/ \
-in csr/$csr_name \
-batch

openssl x509 -in certs/$1.crt -text | grep "X509v3 Subject Alternative Name" -A 1

# Remove temp file
rm $temp_file_name