#!/bin/bash
# Based on https://gist.github.com/fntlnz/cf14feb5a46b2eda428e000157447309

# Generate root key
openssl genrsa \
  -out ../code/terraform/nextcloud/certs/rootCA.key \
  4096

# Generate root certificate
openssl req \
  -x509 \
  -new \
  -nodes \
  -key ../code/terraform/nextcloud/certs/rootCA.key \
  -sha256 \
  -days 1024 \
  -out ../code/terraform/nextcloud/certs/rootCA.crt

# Generate dfr-tfm-nextcloud.duckdns.org key
openssl genrsa \
  -out ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.key \
  4096

# Generate dfr-tfm-nextcloud.duckdns.org certificate
openssl req \
  -new \
  -key ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.key \
  -out ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.csr

openssl req \
  -new -sha256 \
  -key ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.key \
  -subj "/C=US/ST=CA/O=MyOrg, Inc./CN=dfr-tfm-nextcloud.duckdns.org" \
    -reqexts SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "\n[SAN]\nsubjectAltName=DNS:dfr-tfm-nextcloud.duckdns.org,DNS:www.dfr-tfm-nextcloud.duckdns.org")) \
  -out ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.csr

# Verify the certificate
openssl req \
  -in ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.csr \
  -text \
  -noout

# Sign the dfr-tfm-nextcloud.duckdns.org certificate with the root certificate
openssl x509 -req \
  -in ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.csr \
  -CA rootCA.crt \
  -CAkey rootCA.key \
  -CAcreateserial \
  -out ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.crt \
  -days 500 \
  -sha256

# Verify the certificate
openssl x509 \
  -in ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.crt \
  -text \
  -noout

# Generate the certificate chain
cat \
  ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.crt \
  ../code/terraform/nextcloud/certs/rootCA.crt \
  > ../code/terraform/nextcloud/certs/dfr-tfm-nextcloud.duckdns.org.chain.crt
