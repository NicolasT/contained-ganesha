ARG BASE_IMAGE=docker.io/centos
ARG BASE_IMAGE_TAG=8
FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

VOLUME ["/run"]

RUN dnf install -y \
        rpcbind \
        && \
    dnf clean all

VOLUME ["/var/lib/nfs"]

RUN dnf install -y \
        nfs-utils \
        && \
    dnf clean all

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

COPY ganesha.conf.sh /etc/ganesha/ganesha.conf.sh

COPY entrypoint.sh healthcheck.sh /
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

LABEL org.opencontainers.image.authors="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.url="https://github.com/NicolasT/contained-ganesha" \
      org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/images/nfs-ganesha/README.md" \
      org.opencontainers.image.source="https://github.com/NicolasT/contained-ganesha.git" \
      org.opencontainers.image.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.licenses="LGPL-3.0" \
      org.opencontainers.image.title="nfs-ganesha" \
      org.opencontainers.image.description="NFS-GANESHA is a NFS Server running in user space. It comes with various back-end modules (called FSALs) provided as shared objects to support different file systems and name-spaces." \
      \
      org.label-schema.schema-version="1.0" \
      org.label-schema.license="LGPL-3.0" \
      org.label-schema.url="https://github.com/NicolasT/contained-ganesha" \
      org.label-schema.vcs-url="https://github.com/NicolasT/contained-ganesha.git" \
      org.label-schema.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.label-schema.name="nfs-ganesha" \
      org.label-schema.description="NFS-GANESHA is a NFS Server running in user space. It comes with various back-end modules (called FSALs) provided as shared objects to support different file systems and name-spaces." \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/images/nfs-ganesha/README.md" \
      org.label-schema.docker.params="NLOCKMGR_PORT=port for the nlockmgr service to bind on, RQUOTAD_PORT=port for the rquotad service to bind on, NFS_PORT=port for the nfs service to bind on, MOUNTD_PORT=port for the mountd service to bind on" \
      org.label-schema.docker.cmd="docker run -d -p ${NLOCKMGR_PORT}:${NLOCKMGR_PORT} -p ${RQUOTAD_PORT}:${RQUOTAD_PORT} -p ${NFS_PORT}:${NFS_PORT} -p ${MOUNTD_PORT}:${MOUNTD_PORT} --cap-drop ALL --cap-add CHOWN --cap-add DAC_OVERRIDE --cap-add DAC_READ_SEARCH --cap-add FOWNER --cap-add FSETID --cap-add NET_BIND_SERVICE --cap-add SETGID --cap-add SETUID --read-only -v ./exports.conf:/etc/ganesha/ganesha.conf.d/exports.conf:ro --tmpfs /run -v dbus-daemon-run:/run/dbus:ro --tmpfs /var/lib/nfs/ganesha contained-ganesha/nfs-ganesha" \
      org.label-schema.docker.cmd.debug="docker exec -it \$CONTAINER /bin/bash" \
      \
      app.kubernetes.io/name="nfs-ganesha" \
      app.kubernetes.io/component="nfs" \
      app.kubernetes.io/part-of="contained-ganesha"
