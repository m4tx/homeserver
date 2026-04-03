#!/usr/bin/env bash

set -e -o pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source_backup_conf> <offsite_backup_conf>"
  exit 1
fi

SOURCE_CONF_PATH=$1
OFFSITE_CONF_PATH=$2

EXPECTED_PERMS="400"

for CONF in "$SOURCE_CONF_PATH" "$OFFSITE_CONF_PATH"; do
  if [[ ! -f "$CONF" ]]; then
    echo "$CONF does not exist"
    exit 1
  fi
  PERMS=$(stat -c '%a' "$CONF")
  if [[ "$PERMS" != "$EXPECTED_PERMS" ]]; then
    echo "$CONF permissions are $PERMS instead of $EXPECTED_PERMS; please execute \`sudo chmod $EXPECTED_PERMS $CONF\` before running the backup script"
    exit 1
  fi
done

# We use a subshell to avoid clashing variables if they have the same names
SOURCE_REPO=$(source "$SOURCE_CONF_PATH"; echo "$RESTIC_REPOSITORY")
SOURCE_PASSWORD=$(source "$SOURCE_CONF_PATH"; echo "$RESTIC_PASSWORD")

source "$OFFSITE_CONF_PATH"
export RESTIC_REPOSITORY RESTIC_PASSWORD AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

# Copy snapshots from local to offsite
echo "Copying snapshots from $SOURCE_REPO to $RESTIC_REPOSITORY..."
restic copy \
  --verbose \
  --from-repo "$SOURCE_REPO" \
  --from-password-file <(echo -n "$SOURCE_PASSWORD")

restic prune

restic check
