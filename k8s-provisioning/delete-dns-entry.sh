#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# check whether rancher entry already exists
set +e
RECORD_EXISTS=$(hetznerdns-cli record get --name rancher --zone-name ${DOMAIN})
if $(echo "${RECORD_EXISTS}" | grep -q RecordNotExistException) 
then
    echo "record 'rancher' in domain '${DOMAIN}' does not exist"
else
    hetznerdns-cli record delete --name rancher --zone-name ${DOMAIN}
fi
