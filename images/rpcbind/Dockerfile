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

LABEL org.opencontainers.image.authors="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.url="https://github.com/NicolasT/contained-ganesha" \
      org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/images/rpcbind/README.md" \
      org.opencontainers.image.source="https://github.com/NicolasT/contained-ganesha.git" \
      org.opencontainers.image.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.licenses="BSD-3-Clause" \
      org.opencontainers.image.title="rpcbind" \
      org.opencontainers.image.description="The rpcbind utility is a server that converts RPC program numbers into universal addresses. It must be running on the host to be able to make RPC calls on a server on that machine." \
      \
      org.label-schema.schema-version="1.0" \
      org.label-schema.license="BSD-3-Clause" \
      org.label-schema.url="https://github.com/NicolasT/contained-ganesha" \
      org.label-schema.vcs-url="https://github.com/NicolasT/contained-ganesha.git" \
      org.label-schema.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.label-schema.name="rpcbind" \
      org.label-schema.description="The rpcbind utility is a server that converts RPC program numbers into universal addresses. It must be running on the host to be able to make RPC calls on a server on that machine." \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/images/rpcbind/README.md" \
      org.label-schema.docker.params="" \
      org.label-schema.docker.cmd="docker run -d -p ${PORTMAPPER_PORT}:${PORTMAPPER_PORT} --cap-drop ALL --cap-add DAC_OVERRIDE --cap-add CHOWN --cap-add NET_BIND_SERVICE --cap-add SETGID --cap-add SETUID --read-only --tmpfs /run contained-ganesha/rpcbind" \
      org.label-schema.docker.cmd.debug="docker exec -it \$CONTAINER /bin/bash" \
      \
      app.kubernetes.io/name="rpcbind" \
      app.kubernetes.io/component="portmapper" \
      app.kubernetes.io/part-of="contained-ganesha"
