#!/usr/bin/env bash

echo "Executing this scripts re-generates your ROOT CA Key and Certificate !"
read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi

rm -rf my-safe-directory
mkdir my-safe-directory

openssl genrsa -out my-safe-directory/ca.key 8096
chmod 400 my-safe-directory/ca.key

openssl req \
-new \
-x509 \
-config ca.cnf \
-key my-safe-directory/ca.key \
-out certs/ca.crt \
-days 3650 \
-batch

rm -f index.txt serial.txt
touch index.txt
echo '01' > serial.txt