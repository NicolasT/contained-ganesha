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

COPY entrypoint.sh healthcheck.sh /
ENTRYPOINT ["/entrypoint.sh"]
HEALTHCHECK CMD ["/healthcheck.sh"]

ARG STATUS_PORT
ENV STATUS_PORT=${STATUS_PORT}
EXPOSE ${STATUS_PORT}/tcp
EXPOSE ${STATUS_PORT}/udp

LABEL org.opencontainers.image.authors="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.url="https://github.com/NicolasT/contained-ganesha" \
      org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/images/rpc.statd/README.md" \
      org.opencontainers.image.source="https://github.com/NicolasT/contained-ganesha.git" \
      org.opencontainers.image.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.opencontainers.image.title="rpc.statd" \
      org.opencontainers.image.description="NSM service daemon" \
      \
      org.label-schema.schema-version="1.0" \
      org.label-schema.license="BSD-3-Clause" \
      org.label-schema.url="https://github.com/NicolasT/contained-ganesha" \
      org.label-schema.vcs-url="https://github.com/NicolasT/contained-ganesha.git" \
      org.label-schema.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.label-schema.name="rpc.statd" \
      org.label-schema.description="NSM service daemon" \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/images/rpc.statd/README.md" \
      org.label-schema.docker.params="STATUS_PORT=port for the status service to bind on" \
      org.label-schema.docker.cmd="docker run -d -p ${STATUS_PORT}:${STATUS_PORT} --cap-drop ALL --cap-add DAC_OVERRIDE --cap-add CHOWN --cap-add NET_BIND_SERVICE --cap-add SETGID --cap-add SETPCAP --cap-add SETUID --read-only --tmpfs /run --tmpfs /var/lib/nfs contained-ganesha/rpc.statd" \
      org.label-schema.docker.cmd.debug="docker exec -it \$CONTAINER /bin/bash" \
      \
      app.kubernetes.io/name="rpc.statd" \
      app.kubernetes.io/component="status" \
      app.kubernetes.io/part-of="contained-ganesha"
