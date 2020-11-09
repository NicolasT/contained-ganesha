#!/bin/bash

set -xue -o pipefail

GANESHA_CONFIG_SCRIPT=/etc/ganesha/ganesha.conf.sh
GANESHA_CONFIG=/run/ganesha/ganesha.conf

/usr/bin/install -v --directory --group=root --mode 0755 --owner=root /run/ganesha

rm -f ${GANESHA_CONFIG}
if test -f /etc/ganesha/ganesha.conf; then
    cp /etc/ganesha/ganesha.conf ${GANESHA_CONFIG}
else
    ${GANESHA_CONFIG_SCRIPT} > ${GANESHA_CONFIG}
fi
test -f ${GANESHA_CONFIG}

TIMEOUT=10
RPCBIND_UP=0
RPC_STATD_UP=0
DBUS_DAEMON_UP=0

for i in `seq 1 $TIMEOUT`; do
    echo "Waiting for rpcbind to be up ($i/$TIMEOUT)..."
    set +e
    ( ulimit -n 1024 && exec /usr/sbin/rpcinfo -T tcp 127.0.0.1 100000 4 )
    result=$?
    set -e

    if [ $result -eq 0 ]; then
        echo "rpcbind listening"
	RPCBIND_UP=1
	break
    fi

    sleep 1
done

if [ $RPCBIND_UP -ne 1 ]; then
    echo "Timeout while waiting for rpcbind to be up" > /dev/stderr
    exit 1
fi

for i in `seq 1 $TIMEOUT`; do
    echo "Waiting for rpc.statd to be up ($i/$TIMEOUT)..."
    set +e
    ( ulimit -n 1024 && exec /usr/sbin/rpcinfo -T tcp 127.0.0.1 100024 1 )
    result=$?
    set -e

    if [ $result -eq 0 ]; then
        echo "rpc.statd listening"
	RPC_STATD_UP=1
	break
    fi

    sleep 1
done

if [ $RPC_STATD_UP -ne 1 ]; then
    echo "Timeout while waiting for rpc.statd to be up" > /dev/stderr
    exit 1
fi

for i in `seq 1 $TIMEOUT`; do
    echo "Waiting for dbus-daemon to be up ($i/$TIMEOUT)..."
    set +e
    test -S /run/dbus/system_bus_socket
    result=$?
    set -e

    if [ $result -eq 0 ]; then
        echo "dbus-daemon listening"
	DBUS_DAEMON_UP=1
	break
    fi

    sleep 1
done

if [ $DBUS_DAEMON_UP -ne 1 ]; then
    echo "Timeout while waiting for dbus-daemon to be up" > /dev/stderr
    exit 1
fi

exec /usr/bin/ganesha.nfsd -F -L /dev/stderr -f ${GANESHA_CONFIG} -p /run/ganesha/ganesha.pid "$@"
