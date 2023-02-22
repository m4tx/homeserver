#!/usr/bin/env bash

set -e -o pipefail

cd /root
git clone https://github.com/m4tx/homeserver.git
./homeserver/install.sh
