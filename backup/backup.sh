#!/usr/bin/env bash

set -e -o pipefail

chmod 400 /etc/backup.conf
source /etc/backup.conf
export RESTIC_REPOSITORY RESTIC_PASSWORD

RETENTION_DAYS=7
RETENTION_WEEKS=4
RETENTION_MONTHS=18
RETENTION_YEARS=3

BACKUP_TAG=auto

restic \
  backup \
  /etc \
  /home \
  /root \
  /var/lib/docker \
  --verbose \
  --one-file-system \
  --tag=$BACKUP_TAG \
  --exclude='/home/*/projects/' \
  --exclude='/home/*/.local/share' \
  --exclude='/home/*/Videos/' \
  --exclude='/home/*/.cache' \
  --exclude='/home/*/Downloads/' \
  --exclude='/home/*/.debug/' \
  --exclude='/home/*/.rustup/' \
  --exclude='/home/*/.cargo/' \
  --exclude='/home/*/Music/' \
  --exclude='/var/lib/docker/overlay2' \
  --exclude-caches

restic forget \
  --verbose \
  --tag $BACKUP_TAG \
  --prune \
  --keep-daily $RETENTION_DAYS \
  --keep-weekly $RETENTION_WEEKS \
  --keep-monthly $RETENTION_MONTHS \
  --keep-yearly $RETENTION_YEARS

restic check
