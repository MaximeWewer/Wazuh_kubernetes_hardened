#!/bin/bash
# Generate certificates for your Wazuh cluster

OPENSEARCH_DN="/C=FR/ST=ALSACE/L=Strasbourg/O=Company/OU=Wazuh"

DIR=$(dirname $(readlink -f $0))
mkdir -p ${DIR}/out/

# Root CA
openssl genrsa -out ${DIR}/out/root-ca.key 2048
openssl req -new -x509 -sha256 -days 1095 -subj "$OPENSEARCH_DN/CN=ca" -key ${DIR}/out/root-ca.key -out ${DIR}/out/root-ca.pem

# Admin
openssl genrsa -out ${DIR}/out/admin_cert-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in ${DIR}/out/admin_cert-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${DIR}/out/admin_cert.key
openssl req -new -subj "$OPENSEARCH_DN/CN=admin_cert" -key ${DIR}/out/admin_cert.key -out ${DIR}/out/admin_cert.csr
openssl x509 -days 365 -req -in ${DIR}/out/admin_cert.csr -CA ${DIR}/out/root-ca.pem -CAkey ${DIR}/out/root-ca.key -CAcreateserial -sha256 -out ${DIR}/out/admin_cert.pem
rm ${DIR}/out/admin_cert-temp.key ${DIR}/out/admin_cert.csr

# Filebeat
openssl genrsa -out ${DIR}/out/filebeat-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in ${DIR}/out/filebeat-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${DIR}/out/filebeat.key
openssl req -new -subj "$OPENSEARCH_DN/CN=filebeat" -key ${DIR}/out/filebeat.key -out ${DIR}/out/filebeat.csr
openssl x509 -days 365 -req -in ${DIR}/out/filebeat.csr -CA ${DIR}/out/root-ca.pem -CAkey ${DIR}/out/root-ca.key -CAcreateserial -sha256 -out ${DIR}/out/filebeat.pem
rm ${DIR}/out/filebeat-temp.key ${DIR}/out/filebeat.csr

# OpenSearch Dashboard
openssl genrsa -out ${DIR}/out/dashboard-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in ${DIR}/out/dashboard-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${DIR}/out/dashboard.key
openssl req -new -subj "$OPENSEARCH_DN/CN=Wazuh Dashboard" -key ${DIR}/out/dashboard.key -out ${DIR}/out/dashboard.csr
openssl x509 -days 365 -req -in ${DIR}/out/dashboard.csr -CA ${DIR}/out/root-ca.pem -CAkey ${DIR}/out/root-ca.key -CAcreateserial -sha256 -out ${DIR}/out/dashboard.pem
rm ${DIR}/out/dashboard-temp.key ${DIR}/out/dashboard.csr

# Opensearch Nodes
openssl genrsa -out ${DIR}/out/wildcard.indexer-temp.key 2048
openssl pkcs8 -inform PEM -outform PEM -in ${DIR}/out/wildcard.indexer-temp.key -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${DIR}/out/wildcard.indexer.key
openssl req -new -subj "$OPENSEARCH_DN/CN=*.wazuh-indexer" -key ${DIR}/out/wildcard.indexer.key -out ${DIR}/out/wildcard.indexer.csr
openssl x509 -days 365 -req -extfile <(printf "subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:wazuh-indexer") -in ${DIR}/out/wildcard.indexer.csr -CA ${DIR}/out/root-ca.pem -CAkey ${DIR}/out/root-ca.key -CAcreateserial -sha256 -out ${DIR}/out/wildcard.indexer.pem
rm ${DIR}/out/wildcard.indexer-temp.key ${DIR}/out/wildcard.indexer.csr