#!/bin/bash

set -ue -o pipefail

source $1

cat << EOF
bases:
  - ../../base

images:
  - name: ${RPCBIND_IMAGE}
    newName: ${LOCAL_RPCBIND_IMAGE}
    newTag: ${LOCAL_RPCBIND_TAG}
  - name: ${RPC_STATD_IMAGE}
    newName: ${LOCAL_RPC_STATD_IMAGE}
    newTag: ${LOCAL_RPC_STATD_TAG}
  - name: ${DBUS_DAEMON_IMAGE}
    newName: ${LOCAL_DBUS_DAEMON_IMAGE}
    newTag: ${LOCAL_DBUS_DAEMON_TAG}
  - name: ${NFS_GANESHA_IMAGE}
    newName: ${LOCAL_NFS_GANESHA_IMAGE}
    newTag: ${LOCAL_NFS_GANESHA_TAG}
  - name: ${GANESHA_CONFIG_RELOAD_IMAGE}
    newName: ${LOCAL_GANESHA_CONFIG_RELOAD_IMAGE}
    newTag: ${LOCAL_GANESHA_CONFIG_RELOAD_TAG}

patchesJson6902:
- target:
    group: apps
    version: v1
    kind: StatefulSet
    name: nfs-ganesha
  path: image-pull-policy-patch.yml
EOF
