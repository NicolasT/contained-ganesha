#!/bin/bash

set -xue -o pipefail

/usr/bin/install --directory --owner=root --group=root --mode=0755 /run/dbus
/usr/bin/systemd-tmpfiles --create /usr/lib/tmpfiles.d/dbus.conf

/usr/bin/dbus-uuidgen --ensure

exec /usr/bin/dbus-daemon --nofork --nopidfile --nosyslog "$@"
