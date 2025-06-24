#!/bin/bash

# Exit on error
set -e

# Check for openssl
command -v openssl >/dev/null 2>&1 || {
  echo >&2 "Errore: OpenSSL non è installato. Installalo prima di eseguire lo script."
  exit 1
}

# Input parameters
CLIENT_NAME=${1:-sacmi}
PFX_PASSWORD=${2:-changeit}

# Define filenames
CONF_FILE="${CLIENT_NAME}.conf"
KEY_FILE="${CLIENT_NAME}.key"
CRT_FILE="${CLIENT_NAME}.crt"
PFX_FILE="${CLIENT_NAME}.pfx"
CSR_FILE="${CLIENT_NAME}.csr"

# Check if config file exists
if [ ! -f "$CONF_FILE" ]; then
  echo "Errore: file di configurazione '$CONF_FILE' non trovato."
  exit 1
fi

echo "Generazione certificato per '$CLIENT_NAME'..."

# Generate private key
openssl genrsa -out "$KEY_FILE" 2048

# Generate certificate signing request (CSR)
openssl req -new -key "$KEY_FILE" -out "$CSR_FILE" -config "$CONF_FILE"

# Generate self-signed certificate
openssl x509 -req -in "$CSR_FILE" -signkey "$KEY_FILE" -out "$CRT_FILE" -days 825 -extensions v3_req -extfile "$CONF_FILE"

# Generate PFX file for Kestrel
openssl pkcs12 -export -out "$PFX_FILE" -inkey "$KEY_FILE" -in "$CRT_FILE" -password pass:"$PFX_PASSWORD"

# Cleanup CSR
rm "$CSR_FILE"

echo "Generati con successo:"
echo " - Chiave privata: $KEY_FILE"
echo " - Certificato: $CRT_FILE"
echo " - PFX per Kestrel: $PFX_FILE (password: $PFX_PASSWORD)"
