ARG BASE_IMAGE=docker.io/centos
ARG BASE_IMAGE_TAG=8
FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

VOLUME ["/run"]

RUN dnf install -y \
        rpcbind \
        && \
    dnf clean all

COPY entrypoint.sh healthcheck.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-d", "-s"]
HEALTHCHECK CMD ["/healthcheck.sh"]

ARG PORTMAPPER_PORT
EXPOSE ${PORTMAPPER_PORT}/tcp
EXPOSE ${PORTMAPPER_PORT}/udp
