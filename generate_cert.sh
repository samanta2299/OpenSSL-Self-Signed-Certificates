#!/bin/bash

# Exit on error
set -e

# Define filenames
CONF_FILE="sacmi.conf"
KEY_FILE="sacmi.key"
CRT_FILE="sacmi.crt"
PFX_FILE="sacmi.pfx"
CSR_FILE="sacmi.csr"

# Generate private key
openssl genrsa -out $KEY_FILE 2048

# Generate certificate signing request (CSR)
openssl req -new -key $KEY_FILE -out $CSR_FILE -config $CONF_FILE

# Generate self-signed certificate
openssl x509 -req -in $CSR_FILE -signkey $KEY_FILE -out $CRT_FILE -days 825 -extensions v3_req -extfile $CONF_FILE

# Generate PFX file for Kestrel
openssl pkcs12 -export -out $PFX_FILE -inkey $KEY_FILE -in $CRT_FILE -password pass:changeit

# Cleanup CSR
rm $CSR_FILE

echo "Certificate generation complete:"
echo " - Private Key: $KEY_FILE"
echo " - Certificate: $CRT_FILE"
echo " - PFX for Kestrel: $PFX_FILE (password: changeit)"