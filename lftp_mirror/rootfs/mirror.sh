#!/bin/bash
set -e

DIRECTION="$1"
SITE="$2"
SOURCE="$3"
TARGET="$4"
USERNAME="$5"
INTERVAL="$6"
MAX_INTERVALS="$7"
EXPIRATION="$8"

get_md5sum () {
    if [ "$MAX_INTERVALS" -ne 0 ]
    then
        # shellcheck disable=SC2012
        NEW_MD5=$(ls -1Rln --full-time "$LOCAL" | md5sum)
    fi
}

mirror () {
    # If expiration is defined, remove local files older than the expiration (in days)
    if [ "$EXPIRATION" -gt 0 ]
    then
        find "$LOCAL" -mtime "+$EXPIRATION" -delete
    fi

    # shellcheck disable=SC2140
    lftp --norc -c "$LFTP_SETTINGS;open --user "\""$USERNAME"\"" --env-password "\""$SITE"\"";mirror$REVERSE $MIRROR_OPTIONS "\""$SOURCE"\"" "\""$TARGET"\"
}

if [ "$DIRECTION" = 'upload' ]
then
    REVERSE=' --reverse'
    LOCAL="$SOURCE"
    NEW_MD5=0
    get_md5sum
    LAST_MD5="$NEW_MD5"
    mirror
    INTERVAL_COUNT=0
    # inotifywait does not work reliably between Docker containers, otherwise this would be a better solution than polling:
    # while inotifywait --event create --event modify --event moved_to --event delete --recursive --timeout $INTERVAL "$LOCAL"
    while sleep "$INTERVAL"
    do
        get_md5sum
        if [ "$INTERVAL_COUNT" -ge "$MAX_INTERVALS" ] || [ "$NEW_MD5" != "$LAST_MD5" ]
        then
          LAST_MD5="$NEW_MD5"
          mirror
          INTERVAL_COUNT=0
        else
          INTERVAL_COUNT=$((INTERVAL_COUNT + 1))
        fi
    done
else
    REVERSE=
    LOCAL="$TARGET"
    mirror
    while sleep "$INTERVAL"
    do
        mirror
    done
fi
