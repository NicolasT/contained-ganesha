#!/bin/bash

set -ue -o pipefail

source $1

cat << EOF
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: nfs-ganesha
  labels:
    app: contained-ganesha
    component: nfs-ganesha
spec:
  selector:
    matchLabels:
      app: contained-ganesha
      component: nfs-ganesha
  serviceName: nfs-ganesha-headless
  replicas: 1
  template:
    metadata:
      labels:
        app: contained-ganesha
        component: nfs-ganesha
    spec:
      automountServiceAccountToken: false

      containers:
        - name: nfs-ganesha
          image: ${NFS_GANESHA_IMAGE}:${NFS_GANESHA_TAG}
          env:
            - name: NLOCKMGR_PORT
              value: "${NLOCKMGR_PORT}"
            - name: RQUOTAD_PORT
              value: "${RQUOTAD_PORT}"
            - name: NFS_PORT
              value: "${NFS_PORT}"
            - name: MOUNTD_PORT
              value: "${MOUNTD_PORT}"
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
              add:
                - CHOWN
                - DAC_OVERRIDE
                - DAC_READ_SEARCH
                - FOWNER
                - FSETID
                - NET_BIND_SERVICE
                - SETGID
                - SETUID
          ports:
            - name: nlockmgr-tcp
              containerPort: ${NLOCKMGR_PORT}
              protocol: TCP
            - name: nlockmgr-udp
              containerPort: ${NLOCKMGR_PORT}
              protocol: UDP
            - name: rquotad-tcp
              containerPort: ${RQUOTAD_PORT}
              protocol: TCP
            - name: rquotad-udp
              containerPort: ${RQUOTAD_PORT}
              protocol: UDP
            - name: nfs-tcp
              containerPort: ${NFS_PORT}
              protocol: TCP
            - name: nfs-udp
              containerPort: ${NFS_PORT}
              protocol: UDP
            - name: mountd-tcp
              containerPort: ${MOUNTD_PORT}
              protocol: TCP
            - name: mountd-udp
              containerPort: ${MOUNTD_PORT}
              protocol: UDP
          livenessProbe:
            tcpSocket:
              port: nfs-tcp
          readinessProbe:
            exec:
              command: ["/healthcheck.sh"]
            timeoutSeconds: 10
          terminationMessagePolicy: FallbackToLogsOnError
          volumeMounts:
            - name: run
              mountPath: /run
            - name: dbus-daemon-run
              mountPath: /run/dbus
              readOnly: true
            - name: nfs-ganesha-lib
              mountPath: /var/lib/nfs/ganesha
            - name: nfs-ganesha-tmp
              mountPath: /tmp
            - name: nfs-ganesha-config
              mountPath: /etc/ganesha/ganesha.conf.d
              readOnly: true

        - name: rpcbind
          image: ${RPCBIND_IMAGE}:${RPCBIND_TAG}
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
              add:
                - DAC_OVERRIDE
                - CHOWN
                - NET_BIND_SERVICE
                - SETGID
                - SETUID
          ports:
            - name: portmapper-tcp
              containerPort: ${PORTMAPPER_PORT}
              protocol: TCP
            - name: portmapper-udp
              containerPort: ${PORTMAPPER_PORT}
              protocol: UDP
          livenessProbe:
            tcpSocket:
              port: portmapper-tcp
          readinessProbe:
            exec:
              command: ["/healthcheck.sh"]
            timeoutSeconds: 10
          terminationMessagePolicy: FallbackToLogsOnError
          volumeMounts:
            - name: run
              mountPath: /run

        - name: rpc-statd
          image: ${RPC_STATD_IMAGE}:${RPC_STATD_TAG}
          env:
            - name: STATUS_PORT
              value: "${STATUS_PORT}"
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
              add:
                - DAC_OVERRIDE
                - CHOWN
                - NET_BIND_SERVICE
                - SETGID
                - SETPCAP
                - SETUID
          ports:
            - name: status-tcp
              containerPort: ${STATUS_PORT}
              protocol: TCP
            - name: status-udp
              containerPort: ${STATUS_PORT}
              protocol: UDP
          livenessProbe:
            tcpSocket:
              port: status-tcp
          readinessProbe:
            exec:
              command: ["/healthcheck.sh"]
            timeoutSeconds: 10
          terminationMessagePolicy: FallbackToLogsOnError
          volumeMounts:
            - name: run
              mountPath: /run
            - name: rpc-statd-lib
              mountPath: /var/lib/nfs

        - name: dbus-daemon
          image: ${DBUS_DAEMON_IMAGE}:${DBUS_DAEMON_TAG}
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
              add:
                - SETGID
                - SETPCAP
                - SETUID
          livenessProbe:
            exec:
              command: ["/healthcheck.sh"]
            timeoutSeconds: 10
          terminationMessagePolicy: FallbackToLogsOnError
          volumeMounts:
            - name: dbus-daemon-run
              mountPath: /run/dbus
            - name: dbus-daemon-lib
              mountPath: /var/lib/dbus

      volumes:
        - name: nfs-ganesha-lib
          emptyDir:
        - name: nfs-ganesha-tmp
          emptyDir:
            medium: Memory
        - name: nfs-ganesha-config
          configMap:
            name: nfs-ganesha
        - name: run
          emptyDir:
            medium: Memory
        - name: rpc-statd-lib
          emptyDir:
        - name: dbus-daemon-run
          emptyDir:
            medium: Memory
        - name: dbus-daemon-lib
          emptyDir:
EOF
