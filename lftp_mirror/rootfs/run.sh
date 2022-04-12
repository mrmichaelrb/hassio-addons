#!/usr/bin/with-contenv bashio
set -e

get_config () {
    local VARIABLE_NAME=${1}
    local CONFIG_NAME=${2}
    if bashio::config.has_value "directories[${DIRECTORY}].$CONFIG_NAME"
    then
        local CONFIG_VALUE
        CONFIG_VALUE=$(bashio::config "directories[${DIRECTORY}].$CONFIG_NAME")
        printf -v "$VARIABLE_NAME" '%s' "$CONFIG_VALUE"
    fi
}

add_lftp_setting () {
    local CONFIG_NAME=${1}
    local SETTING_NAME=${2}
    if bashio::config.has_value "directories[${DIRECTORY}].$CONFIG_NAME"
    then
        local SETTING_VALUE
        SETTING_VALUE=$(bashio::config "directories[${DIRECTORY}].$CONFIG_NAME")
        LFTP_SETTINGS+="set $SETTING_NAME $SETTING_VALUE;"
    fi
}

bool_mirror_option () {
    local OPTION_NAME=${1}
    if bashio::config.true "directories[${DIRECTORY}].$OPTION_NAME"
    then
        MIRROR_OPTIONS+=" --${OPTION_NAME//_/-}"
    fi
}

int_mirror_option () {
    local OPTION_NAME=${1}
    if bashio::config.has_value "directories[${DIRECTORY}].$OPTION_NAME"
    then
        local OPTION_VALUE
        OPTION_VALUE=$(bashio::config "directories[${DIRECTORY}].$OPTION_NAME")
        MIRROR_OPTIONS+=" --${OPTION_NAME//_/-}=$OPTION_VALUE"
    fi
}

str_mirror_option () {
    local OPTION_NAME=${1}
    if bashio::config.has_value "directories[${DIRECTORY}].$OPTION_NAME"
    then
        local OPTION_VALUE
        OPTION_VALUE=$(bashio::config "directories[${DIRECTORY}].$OPTION_NAME")
        # shellcheck disable=SC2140
        MIRROR_OPTIONS+=" --${OPTION_NAME//_/-}="\""$OPTION_VALUE"\"
    fi
}

NUM_CHILDREN=0

for DIRECTORY in $(bashio::config 'directories|keys')
do
    DIRECTION=$(bashio::config "directories[${DIRECTORY}].direction")
    SITE=$(bashio::config "directories[${DIRECTORY}].site")
    USERNAME=$(bashio::config "directories[${DIRECTORY}].username")
    LFTP_PASSWORD=$(bashio::config "directories[${DIRECTORY}].password")
    export LFTP_PASSWORD
    SOURCE=$(bashio::config "directories[${DIRECTORY}].source")
    TARGET=$(bashio::config "directories[${DIRECTORY}].target")
    INTERVAL=$(bashio::config "directories[${DIRECTORY}].scan_interval")

    MAX_INTERVALS=0
    get_config MAX_INTERVALS max_scan_intervals

    EXPIRATION=0
    get_config EXPIRATION local_expiration_days

    export LFTP_SETTINGS=
    get_config LFTP_SETTINGS more_lftp_settings

    # SFTP confirmation and host key verification should not prevent mirroring
    LFTP_SETTINGS="set sftp:auto-confirm yes;set sftp:connect-program \"ssh -a -x -o UserKnownHostsFile=/dev/null\";$LFTP_SETTINGS"

    # Fish confirmation should not prevent mirroring
    LFTP_SETTINGS="set fish:auto-confirm yes;$LFTP_SETTINGS"

    add_lftp_setting verify_ssl ssl:verify-certificate
    add_lftp_setting net_max_retries net:max-retries
    add_lftp_setting net_reconnect_interval_base net:reconnect-interval-base
    add_lftp_setting net_timeout net:timeout

    export MIRROR_OPTIONS=
    get_config MIRROR_OPTIONS more_mirror_options

    bool_mirror_option continue
    bool_mirror_option delete
    bool_mirror_option delete_first
    bool_mirror_option depth_first
    bool_mirror_option scan_all_first
    bool_mirror_option allow_suid
    bool_mirror_option allow_chown
    bool_mirror_option ignore_time
    bool_mirror_option ignore_size
    bool_mirror_option only_missing
    bool_mirror_option only_existing
    bool_mirror_option only_newer
    bool_mirror_option upload_older
    bool_mirror_option transfer_all
    bool_mirror_option no_empty_dirs
    bool_mirror_option no_recursion
    bool_mirror_option no_symlinks
    bool_mirror_option no_perms
    bool_mirror_option no_umask
    bool_mirror_option dereference
    bool_mirror_option overwrite
    int_mirror_option parallel
    bool_mirror_option loop
    int_mirror_option max_errors
    bool_mirror_option skip_noaccess
    bool_mirror_option verbose

    if bashio::config.true "directories[${DIRECTORY}].remove_source_files"
    then
        MIRROR_OPTIONS+=" --Remove-source-files"
    fi

    if bashio::config.true "directories[${DIRECTORY}].remove_source_dirs"
    then
        MIRROR_OPTIONS+=" --Remove-source-dirs"
    fi

    if [ "$DIRECTION" = 'upload' ]
    then
        # shellcheck disable=SC2140
        bashio::log.info "Mirroring from local "\""$SOURCE"\"" to "\""$TARGET"\"" at "\""$SITE"\""..."
    else
        # shellcheck disable=SC2140
        bashio::log.info "Mirroring from "\""$SOURCE"\"" at "\""$SITE"\"" to local "\""$TARGET"\""..."
    fi

    /mirror.sh "$DIRECTION" "$SITE" "$SOURCE" "$TARGET" "$USERNAME" "$INTERVAL" "$MAX_INTERVALS" "$EXPIRATION" &
    ((NUM_CHILDREN+=1))
done

LFTP_PASSWORD=

# Stay alive while the mirroring child processes are all running
# (account for the check itself creating 1 immediate child)
((NUM_CHILDREN+=1))
while [ "$(pgrep -P $$ | wc -l)" -eq "$NUM_CHILDREN" ]
do
    sleep 5
done
