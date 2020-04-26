# {{{ Common base image
ARG BASE_IMAGE=docker.io/centos
ARG BASE_IMAGE_TAG=8
FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG} as base
# Common labels across all images
LABEL org.opencontainers.image.authors="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.url="https://github.com/NicolasT/contained-ganesha" \
      org.opencontainers.image.source="https://github.com/NicolasT/contained-ganesha.git" \
      org.opencontainers.image.vendor="Nicolas Trangez <https://nicolast.be>" \
      \
      org.label-schema.schema-version="1.0" \
      org.label-schema.url="https://github.com/NicolasT/contained-ganesha" \
      org.label-schema.vcs-url="https://github.com/NicolasT/contained-ganesha.git" \
      org.label-schema.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.label-schema.docker.cmd.debug="docker exec -it \$CONTAINER /bin/bash" \
      \
      app.kubernetes.io/part-of="contained-ganesha"
# }}}

# {{{ A layer which has `rpcbind` installed but no entrypoint etc.
FROM base as intermediate-rpcbind

VOLUME ["/run"]
RUN dnf install -y \
        rpcbind \
	&& \
    dnf clean all
# }}}

# {{{ A layer which has `nfs-utils` installed
FROM intermediate-rpcbind as intermediate-nfs-utils

VOLUME ["/var/lib/nfs"]
RUN dnf install -y \
        nfs-utils \
	&& \
    dnf clean all
# }}}

# {{{ The `rpcbind` images
FROM intermediate-rpcbind as rpcbind

COPY images/rpcbind/entrypoint.sh images/rpcbind/healthcheck.sh images/rpcbind/README.md /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-d", "-s"]
HEALTHCHECK CMD ["/healthcheck.sh"]

ARG PORTMAPPER_PORT
EXPOSE ${PORTMAPPER_PORT}/tcp
EXPOSE ${PORTMAPPER_PORT}/udp

LABEL org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/images/rpcbind/README.md" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.opencontainers.image.title="rpcbind" \
      org.opencontainers.image.description="The rpcbind utility is a server that converts RPC program numbers into universal addresses. It must be running on the host to be able to make RPC calls on a server on that machine." \
      \
      org.label-schema.license="BSD-3-Clause" \
      org.label-schema.name="rpcbind" \
      org.label-schema.description="The rpcbind utility is a server that converts RPC program numbers into universal addresses. It must be running on the host to be able to make RPC calls on a server on that machine." \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/images/rpcbind/README.md" \
      org.label-schema.docker.params="" \
      org.label-schema.docker.cmd="docker run -d -p ${PORTMAPPER_PORT}:${PORTMAPPER_PORT} --cap-drop ALL --cap-add DAC_OVERRIDE --cap-add CHOWN --cap-add NET_BIND_SERVICE --cap-add SETGID --cap-add SETUID --read-only --tmpfs /run contained-ganesha/rpcbind" \
      \
      app.kubernetes.io/name="rpcbind" \
      app.kubernetes.io/component="portmapper"
# }}}

# {{{ The `rpc.statd` image
FROM intermediate-nfs-utils as rpc.statd

COPY images/rpc.statd/entrypoint.sh images/rpc.statd/healthcheck.sh images/rpc.statd/README.md /
ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD ["/healthcheck.sh"]

ARG STATUS_PORT
ENV STATUS_PORT=${STATUS_PORT}
EXPOSE ${STATUS_PORT}/tcp
EXPOSE ${STATUS_PORT}/udp

LABEL org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/images/rpc.statd/README.md" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.opencontainers.image.title="rpc.statd" \
      org.opencontainers.image.description="NSM service daemon" \
      \
      org.label-schema.license="BSD-3-Clause" \
      org.label-schema.name="rpc.statd" \
      org.label-schema.description="NSM service daemon" \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/images/rpc.statd/README.md" \
      org.label-schema.docker.params="STATUS_PORT=port for the status service to bind on" \
      org.label-schema.docker.cmd="docker run -d -p ${STATUS_PORT}:${STATUS_PORT} --cap-drop ALL --cap-add DAC_OVERRIDE --cap-add CHOWN --cap-add NET_BIND_SERVICE --cap-add SETGID --cap-add SETPCAP --cap-add SETUID --read-only --tmpfs /run --tmpfs /var/lib/nfs contained-ganesha/rpc.statd" \
      \
      app.kubernetes.io/name="rpc.statd" \
      app.kubernetes.io/component="status"
# }}}

# {{{ The `dbus-daemon` image
FROM base as dbus-daemon

VOLUME ["/run", "/var/lib/dbus"]

# Note: the `nfs-ganesha` package needs to be installed for the DBus policy
# files to be put in place.
RUN /usr/bin/sed -i 's/ systemd//g' /etc/nsswitch.conf && \
    \
    dnf install -y \
        centos-release-nfs-ganesha30 \
	&& \
    dnf install -y \
        dbus-daemon \
	dbus-tools \
	nfs-ganesha \
	&& \
    dnf clean all

COPY images/dbus-daemon/entrypoint.sh images/dbus-daemon/healthcheck.sh images/dbus-daemon/README.md /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--system"]
HEALTHCHECK CMD ["/healthcheck.sh"]

LABEL org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/images/dbus-daemon/README.md" \
      org.opencontainers.image.licenses="(GPL-2.0+ or AFL-2.1) and GPL-2.0+" \
      org.opencontainers.image.title="dbus-daemon" \
      org.opencontainers.image.description="D-BUS is a system for sending messages between applications. It is used both for the system-wide message bus service, and as a per-user-login-session messaging facility." \
      \
      org.label-schema.license="(GPL-2.0+ or AFL-2.1) and GPL-2.0+" \
      org.label-schema.name="dbus-daemon" \
      org.label-schema.description="D-BUS is a system for sending messages between applications. It is used both for the system-wide message bus service, and as a per-user-login-session messaging facility." \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/images/dbus-daemon/README.md" \
      org.label-schema.docker.params="" \
      org.label-schema.docker.cmd="docker run -d --cap-drop ALL --cap-add SETGID --cap-add SETPCAP --cap-add SETUID --read-only --tmpfs /run/dbus --tmpfs /var/lib/dbus contained-ganesha/dbus-daemon" \
      \
      app.kubernetes.io/name="dbus-daemon" \
      app.kubernetes.io/component="system-bus"
# }}}

# {{{ The `nfs-ganesha` image
FROM intermediate-nfs-utils as nfs-ganesha

# Disable systemd NSS plugin
RUN /usr/bin/sed -i 's/ systemd//g' /etc/nsswitch.conf && \
    \
    dnf install -y \
        centos-release-nfs-ganesha30 \
        && \
    dnf install -y \
        nfs-ganesha \
        nfs-ganesha-mem \
        nfs-ganesha-vfs \
        nfs-ganesha-utils \
        nfs-utils \
        && \
    dnf clean all && \
    \
    rm /etc/ganesha/ganesha.conf && \
    \
    /usr/bin/install -v --directory --group=root --mode 0700 --owner=root /etc/ganesha/ganesha.conf.d && \
    touch /etc/ganesha/ganesha.conf.d/local.conf && \
    touch /etc/ganesha/ganesha.conf.d/exports.conf

COPY images/nfs-ganesha/ganesha.conf.sh /etc/ganesha/ganesha.conf.sh

COPY images/nfs-ganesha/entrypoint.sh images/nfs-ganesha/healthcheck.sh images/nfs-ganesha/README.md /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-N", "NIV_INFO"]
HEALTHCHECK CMD ["/healthcheck.sh"]

ARG NLOCKMGR_PORT
ENV NLOCKMGR_PORT=${NLOCKMGR_PORT}
EXPOSE ${NLOCKMGR_PORT}/tcp
EXPOSE ${NLOCKMGR_PORT}/udp
ARG RQUOTAD_PORT
ENV RQUOTAD_PORT=${RQUOTAD_PORT}
EXPOSE ${RQUOTAD_PORT}/tcp
EXPOSE ${RQUOTAD_PORT}/udp
ARG NFS_PORT
ENV NFS_PORT=${NFS_PORT}
EXPOSE ${NFS_PORT}/tcp
EXPOSE ${NFS_PORT}/udp
ARG MOUNTD_PORT
ENV MOUNTD_PORT=${MOUNTD_PORT}
EXPOSE ${MOUNTD_PORT}/tcp
EXPOSE ${MOUNTD_PORT}/udp

LABEL org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/images/nfs-ganesha/README.md" \
      org.opencontainers.image.licenses="LGPL-3.0" \
      org.opencontainers.image.title="nfs-ganesha" \
      org.opencontainers.image.description="NFS-GANESHA is a NFS Server running in user space. It comes with various back-end modules (called FSALs) provided as shared objects to support different file systems and name-spaces." \
      \
      org.label-schema.license="LGPL-3.0" \
      org.label-schema.name="nfs-ganesha" \
      org.label-schema.description="NFS-GANESHA is a NFS Server running in user space. It comes with various back-end modules (called FSALs) provided as shared objects to support different file systems and name-spaces." \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/images/nfs-ganesha/README.md" \
      org.label-schema.docker.params="NLOCKMGR_PORT=port for the nlockmgr service to bind on, RQUOTAD_PORT=port for the rquotad service to bind on, NFS_PORT=port for the nfs service to bind on, MOUNTD_PORT=port for the mountd service to bind on" \
      org.label-schema.docker.cmd="docker run -d -p ${NLOCKMGR_PORT}:${NLOCKMGR_PORT} -p ${RQUOTAD_PORT}:${RQUOTAD_PORT} -p ${NFS_PORT}:${NFS_PORT} -p ${MOUNTD_PORT}:${MOUNTD_PORT} --cap-drop ALL --cap-add CHOWN --cap-add DAC_OVERRIDE --cap-add DAC_READ_SEARCH --cap-add FOWNER --cap-add FSETID --cap-add NET_BIND_SERVICE --cap-add SETGID --cap-add SETUID --read-only -v ./exports.conf:/etc/ganesha/ganesha.conf.d/exports.conf:ro --tmpfs /run -v dbus-daemon-run:/run/dbus:ro --tmpfs /var/lib/nfs/ganesha contained-ganesha/nfs-ganesha" \
      \
      app.kubernetes.io/name="nfs-ganesha" \
      app.kubernetes.io/component="nfs"
# }}}
