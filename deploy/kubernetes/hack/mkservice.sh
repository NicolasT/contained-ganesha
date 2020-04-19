#!/bin/bash

set -ue -o pipefail

source $1
NAME=$2
CLUSTERIP=$3

cat << EOF
apiVersion: v1
kind: Service
metadata:
  name: ${NAME}
  labels:
    app: contained-ganesha
    component: nfs-ganesha
spec:
  selector:
    app: contained-ganesha
    component: nfs-ganesha
  ${CLUSTERIP}
  sessionAffinity: ClientIP
  ports:
EOF

for port in portmapper status nlockmgr rquotad nfs mountd; do
    PORT_UPPER=$(echo $port | tr a-z A-Z)
    PORT_VAR=$(printf "%s_PORT" $PORT_UPPER)
    PORT_NUM="${!PORT_VAR}"
    for proto in tcp udp; do
        cat << EOF
    - name: ${port}-${proto}
      port: ${PORT_NUM}
      protocol: $(echo $proto | tr a-z A-Z)
      targetPort: ${port}-${proto}
EOF
    done
done
