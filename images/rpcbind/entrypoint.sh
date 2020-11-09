#!/bin/bash

set -xue -o pipefail

/usr/bin/systemd-tmpfiles --create /usr/lib/tmpfiles.d/rpcbind.conf
ulimit -n  1024

exec /usr/bin/rpcbind "$@" -w -f
