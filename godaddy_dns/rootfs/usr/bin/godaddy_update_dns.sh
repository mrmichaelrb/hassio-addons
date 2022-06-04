#!/bin/bash
set -e

ACTION="${1}"
HOSTNAME="${2}"
RECORD_TYPE="${3}"
DATA_VALUE="${4}"

EXIT_CODE=0

if [ "${ACTION}" = 'remove' ]
then
    ANSWER="$(curl -s -X DELETE "https://api.godaddy.com/v1/domains/${GODADDY_DOMAIN}/records/${RECORD_TYPE}/${HOSTNAME}" \
        -H "Authorization: sso-key ${GODADDY_KEY}:${GODADDY_SECRET}")" \
        || EXIT_CODE=${?}
else
    ANSWER="$(curl -s -X PUT "https://api.godaddy.com/v1/domains/${GODADDY_DOMAIN}/records/${RECORD_TYPE}/${HOSTNAME}" \
        -H 'accept: application/json' \
        -H 'Content-Type: application/json' \
        -H "Authorization: sso-key ${GODADDY_KEY}:${GODADDY_SECRET}" \
        -d '[{"data":"'"${DATA_VALUE}"'","ttl":'"${GODADDY_TTL}"'}]')" \
        || EXIT_CODE=${?}
fi

if [ "${ANSWER}" != '' ]
then
    echo "${ANSWER}"
fi

exit ${EXIT_CODE}
