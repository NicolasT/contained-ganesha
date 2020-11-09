#!/bin/bash

set -ue -o pipefail

TRANSPORT=tcp
HOST=127.0.0.1
PROGRAM=100024
VERSION=1

ulimit -n 1024

exec /usr/bin/timeout \
        --kill-after=1s \
        8s \
        /usr/bin/rpcinfo \
            -T ${TRANSPORT} \
            ${HOST} \
            ${PROGRAM} \
            ${VERSION}
