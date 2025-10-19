#!/usr/bin/env bash

set -e -o pipefail

BACKUP_CONF_PATH=/etc/rustic/rustic.toml
EXPECTED_PERMS="400"
PERMS=$(stat -c '%a' "$BACKUP_CONF_PATH")

if [[ "$PERMS" != "$EXPECTED_PERMS" ]]; then
  echo "$BACKUP_CONF_PATH permissions are $PERMS instead of $EXPECTED_PERMS; please execute \`sudo chmod $EXPECTED_PERMS $BACKUP_CONF_PATH\` before running the backup script"
  exit 1
fi

BACKUP_TAG=auto

rustic \
  backup \
  /etc \
  /home \
  /root \
  /var/lib/docker \
  --one-file-system \
  --tag=$BACKUP_TAG \
  --glob='!/home/*/projects/' \
  --glob='!/home/*/.local/share' \
  --glob='!/home/*/Videos/' \
  --glob='!/home/*/.cache' \
  --glob='!/home/*/Downloads/' \
  --glob='!/home/*/.debug/' \
  --glob='!/home/*/.rustup/' \
  --glob='!/home/*/.cargo/' \
  --glob='!/home/*/Music/' \
  --glob='!/var/lib/docker/overlay2' \
  --exclude-if-present "CACHEDIR.TAG" \
  --git-ignore
