#!/bin/bash

set -ue -o pipefail

source $1

cat << EOF
---
apiVersion: v1
kind: Pod
metadata:
  name: nfs-ganesha
  labels:
    app: contained-ganesha
    component: nfs-ganesha
spec:
  automountServiceAccountToken: false
  shareProcessNamespace: true

  containers:
    - name: nfs-ganesha
      image: localhost/${LOCAL_NFS_GANESHA_IMAGE}:${LOCAL_NFS_GANESHA_TAG}
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
      # Podman execs nc in the container for a TCP socket probe,
      # and we don't install that tool in the containers, so the
      # liveness check fails.
      #livenessProbe:
      #  tcpSocket:
      #    port: nfs-tcp
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

    - name: ganesha-config-reload
      image: localhost/${LOCAL_GANESHA_CONFIG_RELOAD_IMAGE}:${LOCAL_GANESHA_CONFIG_RELOAD_TAG}
      args:
        - -mode=configmap
        - -pid=/run/ganesha/ganesha.pid
        - /etc/ganesha/ganesha.conf.d
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
        drop:
          - ALL
      terminationMessagePolicy: FallbackToLogsOnError
      volumeMounts:
        - name: run
          mountPath: /run
          readOnly: true
        - name: nfs-ganesha-config
          mountPath: /etc/ganesha/ganesha.conf.d
          readOnly: true

    - name: rpcbind
      image: localhost/${LOCAL_RPCBIND_IMAGE}:${LOCAL_RPCBIND_TAG}
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
          add:
            - DAC_OVERRIDE
            - CHOWN
            - FOWNER
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
      #livenessProbe:
      #  tcpSocket:
      #    port: portmapper-tcp
      readinessProbe:
        exec:
          command: ["/healthcheck.sh"]
        timeoutSeconds: 10
      terminationMessagePolicy: FallbackToLogsOnError
      volumeMounts:
        - name: run
          mountPath: /run

    - name: rpc-statd
      image: localhost/${LOCAL_RPC_STATD_IMAGE}:${LOCAL_RPC_STATD_TAG}
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
      #livenessProbe:
      #  tcpSocket:
      #    port: status-tcp
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
      image: localhost/${LOCAL_DBUS_DAEMON_IMAGE}:${LOCAL_DBUS_DAEMON_TAG}
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
      emptyDir: {}
    - name: nfs-ganesha-tmp
      emptyDir:
        medium: Memory
    - name: nfs-ganesha-config
      configMap:
        name: nfs-ganesha
    - name: run
      emptyDir: {}
        # There's a bug in podman when sharing Memory-backed EmptyDir
        # volumes between containers: new volumes are created for each
        # container instead of a single tmpfs being shared.
        # Hence falling back to regular mounts.
        #
        # See: https://github.com/containers/podman/issues/24930
        #medium: Memory
    - name: rpc-statd-lib
      emptyDir: {}
    - name: dbus-daemon-run
      emptyDir: {}
        # See note above.
        #medium: Memory
    - name: dbus-daemon-lib
      emptyDir: {}
---
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
    EXPORT
    {
        Export_ID=1;
        Path = "/mem";
        Pseudo = "/mem";
        Access_Type = RW;
        FSAL {
            Name = MEM;
        }
    }
EOF
