#!/bin/bash
set -e

ACTION="${1}"
HOSTNAME="${2}"
RECORD_TYPE="${3}"
DATA_VALUE="${4}"

NOW="$(date +%s)"
AUTH_EXPIRATION_PERIOD=3600
AUTH_RENEWAL_PERIOD=3000

if [ -e "${GOOGLE_CLOUD_DNS_AUTHFILE}" ]; then
    AUTH_UPDATE=$(date +%s -r "${GOOGLE_CLOUD_DNS_AUTHFILE}")
else
    AUTH_UPDATE=0
fi

if [ $((NOW - AUTH_UPDATE)) -ge "${AUTH_RENEWAL_PERIOD}" ]
then
    JWT_SCOPE="https://www.googleapis.com/auth/ndev.clouddns.readwrite"
    JWT_TARGET="https://oauth2.googleapis.com/token"
    JWT_EXPIRATION=$((NOW + AUTH_EXPIRATION_PERIOD))

    JWT_CLAIM_SET=$(echo -n '{"iss":"'${GOOGLE_CLOUD_DNS_EMAIL}'","scope":"'${JWT_SCOPE}'","aud":"'${JWT_TARGET}'","exp":'${JWT_EXPIRATION}',"iat":'${NOW}'}')
    JWT_CLAIM_SET=$(echo -n "${JWT_CLAIM_SET}" | openssl base64 -e)

    JWT_HEADER=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e)
    JWT_UNSIGNED=$(echo -n "${JWT_HEADER}.${JWT_CLAIM_SET}" | tr -d '=\n' | tr '/+' '_-')

    JWT_SIGNATURE=$(echo -n "${JWT_UNSIGNED}" | openssl dgst -sha256 -sign "${GOOGLE_CLOUD_DNS_PEMFILE}" - | openssl base64 -e)
    JWT_SIGNATURE=$(echo -n "${JWT_SIGNATURE}" | tr -d '=\n' | tr '/+' '_-')

    ANSWER=$(curl -s -X POST "${JWT_TARGET}" \
        -H 'Content-Type: application/x-www-form-urlencoded' \
        -d "grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${JWT_UNSIGNED}.${JWT_SIGNATURE}")

    ERROR=$(echo "${ANSWER}" | jq '.error')

    if [ "${ERROR}" != 'null' ]
    then
        ERROR_DESCRIPTION=$(echo "${ANSWER}" | jq '.error_description')
        echo "Google OAuth Error: ${ERROR} - ${ERROR_DESCRIPTION}"
    else
        echo "${ANSWER}" | jq '.access_token' > "${GOOGLE_CLOUD_DNS_AUTHFILE}"
    fi
fi

AUTH_TOKEN=$(cat "${GOOGLE_CLOUD_DNS_AUTHFILE}")
EXIT_CODE=0

function report_error() {

    if [ ${2} -ne 0 ]
    then
        echo "Google Cloud DNS ${1} Failure"
    else
        ERROR=$(echo "${3}" | jq '.error')

        if [ "${ERROR}" != 'null' ]
        then
            ERROR_MESSAGE=$(echo "${ERROR}" | jq '.message')
            if [ "${ERROR_MESSAGE}" != 'null' ]
            then
              echo "Google Cloud DNS ${1} Error: ${ERROR_MESSAGE}"
            else
              echo "Google Cloud DNS ${1} Error"
            fi
        fi
    fi
}

if [ "${ACTION}" = 'set' ] || [ "${ACTION}" = 'remove' ]
then
    ANSWER=$(curl -s -X DELETE "https://dns.googleapis.com/dns/v1/projects/${GOOGLE_CLOUD_DNS_PROJECT}/managedZones/${GOOGLE_CLOUD_DNS_ZONE}/rrsets/${HOSTNAME}./${RECORD_TYPE}" \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        -H 'Accept: application/json') \
        || EXIT_CODE=${?}

    report_error "Delete" ${EXIT_CODE} "${ANSWER}"
fi

if [ "${ACTION}" = 'set' ] || [ "${ACTION}" = 'add' ]
then
    ANSWER=$(curl -s -X POST "https://dns.googleapis.com/dns/v1/projects/${GOOGLE_CLOUD_DNS_PROJECT}/managedZones/${GOOGLE_CLOUD_DNS_ZONE}/rrsets" \
        -H "Authorization: Bearer ${AUTH_TOKEN}" \
        -H 'Accept: application/json' \
        -H 'Content-Type: application/json' \
        -d '{"kind":"dns#resourceRecordSet","name":"'${HOSTNAME}'.","type":"'${RECORD_TYPE}'","ttl":'${GOOGLE_CLOUD_DNS_TTL}',"rrdatas":["'${DATA_VALUE}'"]}') \
        || EXIT_CODE=${?}

    report_error "Post" ${EXIT_CODE} "${ANSWER}"
fi

exit ${EXIT_CODE}
