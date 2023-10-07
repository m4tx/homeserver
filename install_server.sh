#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if [[ $EUID -ne 0 ]];
then
    exec sudo /bin/bash "$0" "$@"
fi

cat >/etc/systemd/system/backup-cleanup@.timer <<EOF
[Unit]
Description=Remove old Restic backups on schedule

[Timer]
OnCalendar=*-*-* 6:00:00
Persistent=true
RandomizedDelaySec=900

[Install]
WantedBy=timers.target
EOF

cat >/etc/systemd/system/backup-cleanup@.service <<EOF
[Unit]
Description=Remove old Restic backups

StartLimitIntervalSec=1800
StartLimitBurst=10

[Service]
Type=simple
Nice=10
User=restic
Group=restic
ExecStart=/srv/homeserver/backup_cleanup.sh /etc/%i.conf
# Grant read access to all files
AmbientCapabilities=CAP_DAC_READ_SEARCH

Restart=on-failure
RestartSec=60s
EOF

systemctl daemon-reload
systemctl enable --now backup-cleanup@backup.timer
