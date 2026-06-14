#!/bin/bash

set -e -o pipefail

UNIT="$1"
HOST="$2"

RESULT=$(systemctl show "$UNIT" --property=Result --value)

if [[ "$RESULT" == "start-limit-hit" ]]; then
  /srv/homeserver/ntfy "🚨 Service Failure: $UNIT" "The unit '$UNIT' on host $HOST failed after exhausting all retries (Result: $RESULT)."
else
  echo "Unit $UNIT failed (Result: $RESULT) - retries remain, not notifying."
fi
