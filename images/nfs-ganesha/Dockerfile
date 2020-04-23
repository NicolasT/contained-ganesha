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
