#!/bin/bash

set -ue -o pipefail

cat << EOF
NFS_Core_Param
{
    NLM_Port = ${NLOCKMGR_PORT};
    Rquota_Port = ${RQUOTAD_PORT};
    NFS_Port = ${NFS_PORT};
    MNT_Port = ${MOUNTD_PORT};

    mount_path_pseudo = true;
}

%include /etc/ganesha/ganesha.conf.d/local.conf
%include /etc/ganesha/ganesha.conf.d/exports.conf
EOF
