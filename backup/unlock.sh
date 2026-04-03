#!/usr/bin/env bash

set -e -o pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <backup_conf> [unlock_options...]"
  exit 1
fi

BACKUP_CONF_PATH=$1
shift

EXPECTED_PERMS="400"
PERMS=$(stat -c '%a' "$BACKUP_CONF_PATH")

if [[ "$PERMS" != "$EXPECTED_PERMS" ]]; then
  echo "$BACKUP_CONF_PATH permissions are $PERMS instead of $EXPECTED_PERMS; please execute \`sudo chmod $EXPECTED_PERMS $BACKUP_CONF_PATH\` before running the backup script"
  exit 1
fi

source "$BACKUP_CONF_PATH"
export RESTIC_REPOSITORY RESTIC_PASSWORD AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

restic unlock "$@"
