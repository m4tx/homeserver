#!/usr/bin/env bash

set -e -o pipefail

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
