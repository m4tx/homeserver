#!/usr/bin/env bash

set -e -o pipefail

if [ "$#" -ne 0 ]; then
  echo "Usage: $0"
  exit 1
fi

BACKUP_CONF_PATH=/etc/rustic/rustic.toml

EXPECTED_PERMS="400"
PERMS=$(stat -c '%a' "$BACKUP_CONF_PATH")

if [[ "$PERMS" != "$EXPECTED_PERMS" ]]; then
  echo "$BACKUP_CONF_PATH permissions are $PERMS instead of $EXPECTED_PERMS; please execute \`sudo chmod $EXPECTED_PERMS $BACKUP_CONF_PATH\` before running the backup script"
  exit 1
fi

RETENTION_DAYS=14
RETENTION_WEEKS=12
RETENTION_MONTHS=12
RETENTION_YEARS=5

BACKUP_TAG=auto

rustic forget \
  --verbose \
  --tag $BACKUP_TAG \
  --prune \
  --keep-daily $RETENTION_DAYS \
  --keep-weekly $RETENTION_WEEKS \
  --keep-monthly $RETENTION_MONTHS \
  --keep-yearly $RETENTION_YEARS

rustic check
