#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

CURDIR=$(dirname $(realpath $0))
INVENTORY="${CURDIR}/../inventory/hosts.hcloud.yml"

IP_ADDRESS=$(ansible-inventory -i ${INVENTORY} --list | jq '._meta.hostvars[].ipv4' -r | head -1)

set +e
RECORD_EXISTS=$(hetznerdns-cli record get --name rancher --zone-name ${DOMAIN})
if $(echo "${RECORD_EXISTS}" | grep -q RecordNotExistException)
then
    echo "record 'rancher' in domain '${DOMAIN}' does not exist, creating"
    hetznerdns-cli record create --name rancher --type A --value ${IP_ADDRESS} --zone-name ${DOMAIN}
fi
