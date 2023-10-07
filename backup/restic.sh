#!/usr/bin/env bash

set -e -o pipefail

if [[ $EUID -ne 0 ]];
then
    exec sudo /bin/bash "$0" "$@"
fi

BACKUP_CONF_PATH=/etc/backup.conf
EXPECTED_PERMS="400"
PERMS=$(stat -c '%a' "$BACKUP_CONF_PATH")

if [[ "$PERMS" != "$EXPECTED_PERMS" ]]; then
  echo "$BACKUP_CONF_PATH permissions are $PERMS instead of $EXPECTED_PERMS; please execute \`sudo chmod $EXPECTED_PERMS $BACKUP_CONF_PATH\` before running the backup script"
  exit 1
fi

source "$BACKUP_CONF_PATH"
export RESTIC_REPOSITORY RESTIC_PASSWORD

sudo -u restic -HE restic "$@"
