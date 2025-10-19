#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if [[ $EUID -ne 0 ]];
then
    exec sudo /bin/bash "$0" "$@"
fi

useradd -r -m -s /sbin/nologin rustic || echo "System account 'rustic' already exists; skipping creating one"

cat >/etc/systemd/system/backup.timer <<EOF
[Unit]
Description=Backup on schedule

[Timer]
OnCalendar=*-*-* 4:00:00
Persistent=true
RandomizedDelaySec=900

[Install]
WantedBy=timers.target
EOF

cat >/etc/systemd/system/backup.service <<EOF
[Unit]
Description=Backup with Restic

StartLimitIntervalSec=1800
StartLimitBurst=10

[Service]
Type=simple
Nice=10
User=rustic
Group=rustic
ExecStart=/srv/homeserver/backup.sh
# Grant read access to all files
AmbientCapabilities=CAP_DAC_READ_SEARCH

Restart=on-failure
RestartSec=60s
EOF

systemctl daemon-reload
systemctl enable --now backup.timer

BACKUP_CONF_PATH=/etc/rustic/rustic.toml
mkdir -p $(dirname $BACKUP_CONF_PATH)
cp -n "${SCRIPT_DIR}"/backup/rustic.toml.example "$BACKUP_CONF_PATH"

chown -R rustic:rustic /srv/homeserver

echo
echo "Backup config path is $BACKUP_CONF_PATH. Please edit if necessary (but remember to change the permissions to 400 after making any changes)."
echo
echo "Installation is now complete!"
