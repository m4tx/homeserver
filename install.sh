#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

cat >/etc/systemd/system/backup.timer <<EOF
[Unit]
Description=Backup on schedule

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

cat >/etc/systemd/system/backup.service <<EOF
[Unit]
Description=Backup with Restic

[Service]
Type=simple
Nice=10
Environment="HOME=/root"
ExecStart=/root/homeserver/backup.sh
EOF

systemctl daemon-reload
systemctl enable --now backup.timer

BACKUP_CONF_PATH=/etc/backup.conf
sudo cp "${SCRIPT_DIR}"/backup/backup.conf.example "$BACKUP_CONF_PATH"

echo
echo "Please edit $BACKUP_CONF_PATH and provide the path to your backup repository and the password."
echo
echo "Installation is now complete!"
