#{{{ Build target
FROM docker.io/golang:1-alpine as ganesha-config-reload-builder

WORKDIR ${GOPATH}/src/ganesha-config-reload
ENV GO111MODULES=on

COPY go.mod go.sum ./
RUN go mod download && \
    go mod verify

COPY . ./

ENV CGO_ENABLED=0
ENV GOOS=${GOOS:-linux}
ENV GOARCH=${GOARCH:-amd64}
RUN go test \
        -v \
	-mod readonly \
	./... \
        && \
    go build \
        -a \
	-ldflags '-w -extldflags "-static"' \
        -mod readonly \
	-tags netgo \
	-trimpath \
	-o bin/ganesha-config-reload \
	.
#}}}

#{{{ The `ganesha-config-reload` image
FROM scratch as ganesha-config-reload

LABEL org.opencontainers.image.authors="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.description="The ganesha-config-reload sidecar detects configuration file updates and sends the config reload signal (SIGHUP) to the NFS-Ganesha process to reload its settings." \
      org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/ganesha-config-reload/README.md" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.url="https://github.com/NicolasT/contained-ganesha" \
      org.opencontainers.image.source="https://github.com/NicolasT/contained-ganesha.git" \
      org.opencontainers.image.title="ganesha-config-reload" \
      org.opencontainers.image.vendor="Nicolas Trangez <https://nicolast.be>" \
      \
      org.label-schema.schema-version="1.0" \
      org.label-schema.description="The ganesha-config-reload sidecar detects configuration file updates and sends the config reload signal (SIGHUP) to the NFS-Ganesha process to reload its settings." \
      org.label-schema.license="Apache-2.0" \
      org.label-schema.name="ganesha-config-reload" \
      org.label-schema.url="https://github.com/NicolasT/contained-ganesha" \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/ganesha-config-reload/README.md" \
      org.label-schema.vcs-url="https://github.com/NicolasT/contained-ganesha.git" \
      org.label-schema.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.label-schema.docker.cmd="docker run -d --cap-drop ALL --read-only --volumes-from nfs-ganesha:ro contained-ganesha/ganesha-config-reload" \
      org.label-schema.docker.cmd.debug="docker exec -it \$CONTAINER /bin/bash" \
      org.label-schema.docker.params="" \
      \
      app.kubernetes.io/component="ganesha-config-reload" \
      app.kubernetes.io/name="nfs-ganesha" \
      app.kubernetes.io/part-of="contained-ganesha"

COPY README.md /README.md

COPY --from=ganesha-config-reload-builder /go/src/ganesha-config-reload/bin/ganesha-config-reload /ganesha-config-reload

ENTRYPOINT ["/ganesha-config-reload"]
#}}}
