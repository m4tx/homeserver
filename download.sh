#!/usr/bin/env bash

set -e -o pipefail

cd /opt
git clone https://github.com/m4tx/m4tx-backup.git
./m4tx-backup/install.sh
