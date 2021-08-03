#!/usr/bin/with-contenv bashio
set -e

get_config () {
    local variable_name=$1
    local config_name=$2
    if bashio::config.has_value "directories[${directory}].$config_name"
    then
        local config_value=$(bashio::config "directories[${directory}].$config_name")
        eval $variable_name=$config_value
    fi
}

add_lftp_setting () {
    local config_name=$1
    local setting_name=$2
    if bashio::config.has_value "directories[${directory}].$config_name"
    then
        local setting_value=$(bashio::config "directories[${directory}].$config_name")
        LFTP_SETTINGS+="set $setting_name $setting_value;"
    fi
}

bool_mirror_option () {
    local option_name=$1
    if bashio::config.true "directories[${directory}].$option_name"
    then
        MIRROR_OPTIONS+=" --${option_name//_/-}"
    fi
}

int_mirror_option () {
    local option_name=$1
    if bashio::config.has_value "directories[${directory}].$option_name"
    then
        local option_value=$(bashio::config "directories[${directory}].$option_name")
        MIRROR_OPTIONS+=" --${option_name//_/-}=$option_value"
    fi
}

str_mirror_option () {
    local option_name=$1
    if bashio::config.has_value "directories[${directory}].$option_name"
    then
        local option_value=$(bashio::config "directories[${directory}].$option_name")
        MIRROR_OPTIONS+=" --${option_name//_/-}="\""$option_value"\"
    fi
}

for directory in $(bashio::config 'directories|keys')
do
    DIRECTION=$(bashio::config "directories[${directory}].direction")
    SITE=$(bashio::config "directories[${directory}].site")
    USERNAME=$(bashio::config "directories[${directory}].username")
    export LFTP_PASSWORD=$(bashio::config "directories[${directory}].password")
    SOURCE=$(bashio::config "directories[${directory}].source")
    TARGET=$(bashio::config "directories[${directory}].target")
    INTERVAL=$(bashio::config "directories[${directory}].scan_interval")

    MAX_INTERVALS=0
    get_config MAX_INTERVALS max_scan_intervals 

    EXPIRATION=0
    get_config EXPIRATION local_expiration_days 

    export LFTP_SETTINGS=
    get_config LFTP_SETTINGS more_lftp_settings 

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

    if bashio::config.true "directories[${directory}].remove_source_files"; then
        MIRROR_OPTIONS+=" --Remove-source-files"
    fi
    if bashio::config.true "directories[${directory}].remove_source_dirs"; then
        MIRROR_OPTIONS+=" --Remove-source-dirs"
    fi

    if [ "$DIRECTION" = 'upload' ]; then
        bashio::log.info "Mirroring from local "\""$SOURCE"\"" to "\""$TARGET"\"" at "\""$SITE"\""..."
    else
        bashio::log.info "Mirroring from "\""$SOURCE"\"" at "\""$SITE"\"" to local "\""$TARGET"\""..."
    fi

    /mirror.sh "$DIRECTION" "$SITE" "$SOURCE" "$TARGET" "$USERNAME" $INTERVAL $MAX_INTERVALS $EXPIRATION &
done

LFTP_PASSWORD=

sleep infinity
