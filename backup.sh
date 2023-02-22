#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

"${SCRIPT_DIR}"/update.sh
"${SCRIPT_DIR}"/backup/backup.sh
