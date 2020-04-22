#!/bin/bash

set -ue -o pipefail

TRANSPORT=tcp
HOST=127.0.0.1
PROGRAM=100003
VERSION=4

exec /usr/bin/timeout \
        --kill-after=1s \
        8s \
        /usr/bin/rpcinfo \
            -T ${TRANSPORT} \
            ${HOST} \
            ${PROGRAM} \
            ${VERSION}
