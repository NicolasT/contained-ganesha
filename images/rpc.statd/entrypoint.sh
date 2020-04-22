#!/bin/bash

set -xue -o pipefail

NFS_LIBDIR=/var/lib/nfs
NFS_USER=root
NFS_GROUP=root
STATD_LIBDIR=/var/lib/nfs/statd
STATD_USER=rpcuser
STATD_GROUP=rpcuser

if test -n "${STATUS_PORT:-}"; then
    PORT_ARG="--port ${STATUS_PORT}"
else
    PORT_ARG=""
fi

test -d /var/lib/nfs

/usr/bin/install -v --directory --group=${STATD_GROUP} --mode 0700 --owner=${STATD_USER} ${STATD_LIBDIR} ${STATD_LIBDIR}/sm ${STATD_LIBDIR}/sm.bak

TIMEOUT=10

for i in `seq 1 $TIMEOUT`; do
    echo "Waiting for rpcbind to be up ($i/$TIMEOUT)..."
    set +e
    /usr/bin/rpcinfo -T tcp 127.0.0.1 100000 4
    result=$?
    set -e

    if [ $result -eq 0 ]; then
        echo "rpcbind listening, starting rpc.statd"
        exec /usr/sbin/rpc.statd --no-syslog --foreground --state-directory-path ${STATD_LIBDIR} ${PORT_ARG} "$@"
    fi

    sleep 1
done

echo "Timeout while waiting for rpcbind to be up" > /dev/stderr
exit 1
