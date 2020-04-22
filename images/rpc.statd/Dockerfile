FROM docker.io/centos:8

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

COPY entrypoint.sh healthcheck.sh /
ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD ["/healthcheck.sh"]

ARG STATUS_PORT
ENV STATUS_PORT=${STATUS_PORT}
EXPOSE ${STATUS_PORT}/tcp
EXPOSE ${STATUS_PORT}/udp
