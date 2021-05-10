#!/bin/sh
set -e
set -x
KEYS_PATH=/data/newman/newman/newman-server/certs/
if [[ ! -e ${KEYS_PATH} ]]; then
    mkdir -p ${KEYS_PATH}
fi

(
  cd /data/certificates/live/groot.gspaces.com
  openssl pkcs12 -export -in fullchain.pem -inkey privkey.pem -out ${KEYS_PATH}/keystore.p12 -name groot -CAfile chain.pem -caname root -password pass:password
  chmod a+r ${KEYS_PATH}/keystore.p12
  chown -R ec2-user:ec2-user /data/newman/newman/newman-server/certs
)
