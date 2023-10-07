#!/usr/bin/env bash

set -e -o pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <backup_conf>"
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
export RESTIC_REPOSITORY RESTIC_PASSWORD

RETENTION_DAYS=14
RETENTION_WEEKS=10
RETENTION_MONTHS=18
RETENTION_YEARS=3

BACKUP_TAG=auto

restic forget \
  --verbose \
  --tag $BACKUP_TAG \
  --prune \
  --keep-daily $RETENTION_DAYS \
  --keep-weekly $RETENTION_WEEKS \
  --keep-monthly $RETENTION_MONTHS \
  --keep-yearly $RETENTION_YEARS

restic check
