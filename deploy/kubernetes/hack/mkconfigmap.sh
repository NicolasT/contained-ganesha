#!/bin/bash

set -ue -o pipefail

SED=${SED:-sed}

EXPORTS_CONF=$1

cat << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: nfs-ganesha
  labels:
    app: contained-ganesha
    component: nfs-ganesha
data:
  local.conf: ''
  exports.conf: |
$(${SED} -e 's/^/    /' ${EXPORTS_CONF})
EOF
