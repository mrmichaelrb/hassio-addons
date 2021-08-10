# Home Assistant Add-on: LFTP Mirror

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "LFTP Mirror" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. In the Add-on's configuration, create an item in the list of directories for each directory that will be mirrored by LFTP.
2. Start the add-on.

View the [LFTP Homepage][lftp] for more information about the features, protocols, settings, and options used in the mirroring operation.

## Configuration

Add-on configuration:

```yaml
directories:
  - direction: upload
    site: ftp://ftp.my-server.com/
    username: myftpuser
    password: mtftppassword
    source: /backup
    target: /my_ftp_path/backup
    verify_ssl: false
    net_max_retries: 2
    net_reconnect_interval_base: 5
    net_timeout: 5
    scan_interval: 3600
    max_scan_intervals: 24
    continue: true
    delete: true
    delete_first: true
    ignore_time: true
  - direction: upload
    site: ftp://ftp.my-server.com/
    username: myftpuser
    password: mtftppassword
    source: /media
    target: /my_ftp_path/media
    verify_ssl: false
    net_max_retries: 2
    net_reconnect_interval_base: 5
    net_timeout: 5
    scan_interval: 5
    max_scan_intervals: 360
    local_expiration_days: 30
    continue: true
    delete: true
    delete_first: true
    depth_first: false
    scan_all_first: false
    allow_suid: false
    allow_chown: false
    ignore_time: true
    ignore_size: false
    only_missing: false
    only_existing: false
    only_newer: false
    upload_older: false
    transfer_all: false
    no_empty_dirs: false
    no_recursion: false
    no_symlinks: false
    no_perms: false
    no_umask: false
    dereference: false
    overwrite: false
    parallel: 1
    loop: false
    max_errors: 1
    skip_noaccess: false
    remove_source_files: false
    remove_source_dirs: false
    more_lftp_settings: null
    more_mirror_options: null
```

### Option group `directories`

The following options are for the option group: `directories`.

#### Option `directories.direction` (required)

`upload`/`download`: The direction of the mirror command.

- `upload`
  
  - The same as the `--reverse` option in the LFTP mirror command. The source directory is local and the target is remote.

- `download`
  
  - The default direction for the LFTP mirror command. The source directory is remote and the target is local.

#### Option `directories.site` (required)

URL or host name of the remote server used in the `open` command by LFTP.
If a host name is specified, then the FTP protocol is used by default.

#### Option `directories.username` (required)

Username to use when authenticating with the remote server.

#### Option `directories.password` (required)

Password to use when authenticating with the remote server.

### Option: `directories.source` (required)

Directory path to use as the source for mirroring.
If the direction is `upload`, then this is a local directory.
If the direction is `download`, then this is a directory on the remote server.

### Option: `directories.target` (required)

Directory path to use as the target for mirroring.
If the direction is `upload`, then this is a directory on the remote server.
If the direction is `download`, then this is a local directory.

### Option: `directories.verify_ssl` (optional)

Sets the `ssl:verify-certificate` variable in LFTP.
If set to true, then verify server's certificate to be signed by a known Certificate Authority and not be on the Certificate Revocation List.

### Option: `directories.net_max_retries` (optional)

Sets the `net:max-retries` variable in LFTP, the maximum number of sequential tries of an operation without success.
0 means unlimited.
1 means no retries.

### Option: `directories.net_reconnect_interval_base` (optional)

Sets the `net:reconnect-interval-base` variable in LFTP, the base minimal time in seconds between reconnects.

### Option: `directories.net_timeout` (optional)

Sets the `net:timeout` variable in LFTP, the network protocol timeout in seconds.

### Option: `directories.scan_interval` (required)

The number of seconds between scanning for changes.
If the direction is `download` a mirror operation is performed every scan interval to detect changes at the remote server.
If the direction is `upload`, a mirror operation is performed if a local scan detects changes.

### Option: `directories.max_scan_intervals` (optional)

If the direction is `upload`, then the number of scan intervals skipped between mirroring operations if no local changes are detected.
0 means a mirror operation is performed every scan interval even if no local changes are detected.

### Option: `directories.local_expiration_days` (optional)

The number of days before old files are removed from the local directory, based on file modification date.
0 means no files are removed.
1 means that files over 1 day old are removed.
> **&#x26a0;&#xfe0f; WARNING: Unintentional data loss is possible, or if the direction is `download`, then files may be repeatedly removed and transferred.**

### Option: `directories.continue` (optional)

Continue a mirror job if possible.
The `--continue` option in the LFTP mirror command.

### Option: `directories.delete` (optional)

Delete files at the target which are not present at the source.
The `--delete` option in the LFTP mirror command.
> **&#x26a0;&#xfe0f; WARNING: Unintentional data loss is possible.**

### Option: `directories.delete_first` (optional)

Delete old files before transferring new ones.
The `--delete-first` option in the LFTP mirror command.

### Option: `directories.depth_first` (optional)

Descend into subdirectories before transferring files.
The `--depth-first` option in the LFTP mirror command.

### Option: `directories.scan_all_first` (optional)

Scan all directories recursively before transferring files.
The `--scan-all-first` option in the LFTP mirror command.

### Option: `directories.allow_suid` (optional)

Set suid/sgid bits according to the source.
The `--allow-suid` option in the LFTP mirror command.

### Option: `directories.allow_chown` (optional)

Try to set owner and group on files.
The `--allow-chown` option in the LFTP mirror command.

### Option: `directories.ignore_time` (optional)

Ignore time when deciding whether to download.
The `--ignore-time` option in the LFTP mirror command.

### Option: `directories.ignore_size` (optional)

Ignore size when deciding whether to download.
The `--ignore-size` option in the LFTP mirror command.

### Option: `directories.only_missing` (optional)

Download only missing files.
The `--only-missing` option in the LFTP mirror command.

### Option: `directories.only_existing` (optional)

Download only files already existing at target.
The `--only-existing` option in the LFTP mirror command.

### Option: `directories.only_newer` (optional)

Download only newer files.
The `--only-newer` option in the LFTP mirror command.

### Option: `directories.upload_older` (optional)

Upload even files older than the target ones.
The `--upload-older` option in the LFTP mirror command.

### Option: `directories.transfer_all` (optional)

Transfer all files, even seemingly the same at the target site.
The `--transfer-all` option in the LFTP mirror command.

### Option: `directories.no_empty_dirs` (optional)

Do not create empty directories (implies `depth_first`).
The `--no-empty-dirs` option in the LFTP mirror command.

### Option: `directories.no_recursion` (optional)

Do not go into subdirectories.
The `--no-recursion` option in the LFTP mirror command.

### Option: `directories.no_symlinks` (optional)

Do not create symbolic links.
The `--no-symlinks` option in the LFTP mirror command.

### Option: `directories.no_perms` (optional)

Do not set file permissions.
The `--no-perms` option in the LFTP mirror command.

### Option: `directories.no_umask` (optional)

Do not apply umask to file modes.
The `--no-umask` option in the LFTP mirror command.

### Option: `directories.dereference` (optional)

Download symbolic links as files.
The `--dereference` option in the LFTP mirror command.

### Option: `directories.overwrite` (optional)

Overwrite plain files without removing them first.
The `--overwrite` option in the LFTP mirror command.

### Option: `directories.parallel` (optional)

Number of files to transfer in parallel.
The `--parallel` option in the LFTP mirror command.

### Option: `directories.loop` (optional)

Repeats mirror operation until no changes found.
The `--loop` option in the LFTP mirror command.
> **&#x26a0;&#xfe0f; WARNING: The LFTP mirror operation has been known to hang when this option is used. Using this option is not recommended.**

### Option: `directories.max_errors` (optional)

Number of errors to ignore before stopping.
The `--max-errors` option in the LFTP mirror command.

### Option: `directories.skip_noaccess` (optional)

Do not try to transfer files with no read access.
The `--skip-noaccess` option in the LFTP mirror command.

### Option: `directories.remove_source_files` (optional)

Remove source files after transfer.
The `--Remove-source-files` option in the LFTP mirror command.
> **&#x26a0;&#xfe0f; WARNING: Unintentional data loss is possible.**

### Option: `directories.remove_source_dirs` (optional)

Remove source files and directories after transfer.
Top level directory is not removed if its name ends with a slash.
The `--Remove-source-dirs` option in the LFTP mirror command.
> **&#x26a0;&#xfe0f; WARNING: Unintentional data loss is possible.**

### Option: `directories.more_lftp_settings` (optional)

Additional LFTP variable settings.
Each setting must be terminated with a semicolon.
Example: `set dns:cache-enable false; set ftp:passive-mode false;`

### Option: `directories.more_mirror_options` (optional)

Additional LFTP mirror command options.
Example: `--ascii --use-pget-n=5`

## Known issues and limitations

- The default timeout and retry settings used by LFTP may cause a mirror operation to hang for long periods of time, so it is recommended that more reasonable values always be specified in the `net_max_retries`, `net_reconnect_interval_base`, and `net_timeout` options.
- The `loop` option may cause a mirror option to hang, so it is recommended that that this option be avoided.
- Some LFTP settings and mirror options are not natively supported, however the `more_lftp_settings` and `more_mirror_options` options allow use of unsupported settings and options.
- Mirroring will fail with `Fatal error: Certificate verification` if your remote server does not have a certificate signed (and not revoked) by a known Certificate Authority, or if the specified hostname (or IP address) in the `site` does not match the name in the certificate. This can be remedied by setting the `verify_ssl` option to false.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Discord Chat Server][discord].
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

In case you've found a bug, please [open an issue on our GitHub][issue].

[discord]: https://discord.gg/c5DvZ4e
[forum]: https://community.home-assistant.io
[issue]: https://github.com/mrmichaelrb/hassio-addons/issues
[reddit]: https://reddit.com/r/homeassistant
[lftp]: https://lftp.yar.ru/
