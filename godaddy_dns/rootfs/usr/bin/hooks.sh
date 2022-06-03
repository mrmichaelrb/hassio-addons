#!/bin/bash
set -e

# Derived in part from:
# https://github.com/lukas2511/dehydrated/blob/master/docs/examples/hook.sh

deploy_challenge() {
    local TOKEN_VALUE="${3}"
    local HOSTNAME="_acme-challenge.${GODADDY_HOSTNAME}"
    godaddy_update_dns.sh set "${HOSTNAME}" TXT "${TOKEN_VALUE}"
    sleep "${LE_DNS_DELAY}"
}

clean_challenge() {
    local HOSTNAME="_acme-challenge.${GODADDY_HOSTNAME}"
    godaddy_update_dns.sh remove "${HOSTNAME}" TXT
}

deploy_cert() {
    local KEYFILE="${2}"
    local FULLCHAINFILE="${4}"
    cp -f "${FULLCHAINFILE}" "/ssl/${LE_CERTFILE}"
    cp -f "${KEYFILE}" "/ssl/${LE_KEYFILE}"
}

HANDLER="${1}"; shift
if [[ "${HANDLER}" =~ ^(deploy_challenge|clean_challenge|deploy_cert)$ ]]
then
    "${HANDLER}" "${@}"
fi
