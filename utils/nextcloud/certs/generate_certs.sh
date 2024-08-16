#!/bin/bash
# Based on https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

# Generate root key
openssl genrsa \
  -out rootCA.key \
  4096

# Generate root certificate
openssl req \
  -x509 \
  -new \
  -nodes \
  -key rootCA.key \
  -sha256 \
  -days 1024 \
  -out rootCA.crt

# Generate dfr-tfm-nextcloud.duckdns.org key
openssl genrsa \
  -out dfr-tfm-nextcloud.duckdns.org.key \
  4096

# Generate dfr-tfm-nextcloud.duckdns.org certificate
openssl req \
  -new \
  -key dfr-tfm-nextcloud.duckdns.org.key \
  -out dfr-tfm-nextcloud.duckdns.org.csr

openssl req \
  -new -sha256 \
  -key dfr-tfm-nextcloud.duckdns.org.key \
  -subj "/C=ES/ST=ES/O=UDC/OU=UDC/CN=dfr-tfm-nextcloud.duckdns.org" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "\n[SAN]\nsubjectAltName=DNS:dfr-tfm-nextcloud.duckdns.org,DNS:www.dfr-tfm-nextcloud.duckdns.org")) \
  -out dfr-tfm-nextcloud.duckdns.org.csr

# Verify the certificate
openssl req \
  -in dfr-tfm-nextcloud.duckdns.org.csr \
  -text \
  -noout

# Sign the dfr-tfm-nextcloud.duckdns.org certificate with the root certificate
openssl x509 -req \
  -in dfr-tfm-nextcloud.duckdns.org.csr \
  -CA rootCA.crt \
  -CAkey rootCA.key \
  -CAcreateserial \
  -out dfr-tfm-nextcloud.duckdns.org.crt \
  -days 500 \
  -sha256

# Verify the certificate
openssl x509 \
  -in dfr-tfm-nextcloud.duckdns.org.crt \
  -text \
  -noout

# Generate the certificate chain
cat \
  dfr-tfm-nextcloud.duckdns.org.crt \
  rootCA.crt \
  > dfr-tfm-nextcloud.duckdns.org.chain.crt
