#!/usr/bin/env bash

set -e -o pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <source_backup_conf> <offsite_backup_conf>"
  exit 1
fi

SOURCE_CONF_PATH=$1
OFFSITE_CONF_PATH=$2

EXPECTED_PERMS="400"

# Check permissions for both
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

# Load source
# We use a subshell to avoid clashing variables if they have the same names
SOURCE_REPO=$(source "$SOURCE_CONF_PATH"; echo "$RESTIC_REPOSITORY")
SOURCE_PASSWORD=$(source "$SOURCE_CONF_PATH"; echo "$RESTIC_PASSWORD")

# Load offsite
source "$OFFSITE_CONF_PATH"
# RESTIC_REPOSITORY and RESTIC_PASSWORD are now the offsite ones
export RESTIC_REPOSITORY RESTIC_PASSWORD

# Copy snapshots from local to offsite
echo "Copying snapshots from $SOURCE_REPO to $RESTIC_REPOSITORY..."
restic copy \
  --verbose \
  --from-repo "$SOURCE_REPO" \
  --from-password-file <(echo -n "$SOURCE_PASSWORD")

# Aggressive retention (keep less)
# Default values
RETENTION_DAYS=7
RETENTION_WEEKS=4
RETENTION_MONTHS=6
RETENTION_YEARS=1

# Allow overrides from config (prefixed with OFFSITE_)
RETENTION_DAYS=${OFFSITE_RETENTION_DAYS:-$RETENTION_DAYS}
RETENTION_WEEKS=${OFFSITE_RETENTION_WEEKS:-$RETENTION_WEEKS}
RETENTION_MONTHS=${OFFSITE_RETENTION_MONTHS:-$RETENTION_MONTHS}
RETENTION_YEARS=${OFFSITE_RETENTION_YEARS:-$RETENTION_YEARS}

BACKUP_TAG=auto

echo "Pruning offsite repository with aggressive retention..."
restic forget \
  --verbose \
  --tag $BACKUP_TAG \
  --prune \
  --keep-daily $RETENTION_DAYS \
  --keep-weekly $RETENTION_WEEKS \
  --keep-monthly $RETENTION_MONTHS \
  --keep-yearly $RETENTION_YEARS

restic check
