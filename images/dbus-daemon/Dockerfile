ARG BASE_IMAGE=docker.io/centos
ARG BASE_IMAGE_TAG=8
FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

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

COPY entrypoint.sh healthcheck.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["--system"]
HEALTHCHECK CMD ["/healthcheck.sh"]

LABEL org.opencontainers.image.authors="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.url="https://github.com/NicolasT/contained-ganesha" \
      org.opencontainers.image.documentation="https://github.com/NicolasT/contained-ganesha/blob/master/images/dbus-daemon/README.md" \
      org.opencontainers.image.source="https://github.com/NicolasT/contained-ganesha.git" \
      org.opencontainers.image.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.opencontainers.image.licenses="(GPL-2.0+ or AFL-2.1) and GPL-2.0+" \
      org.opencontainers.image.title="dbus-daemon" \
      org.opencontainers.image.description="D-BUS is a system for sending messages between applications. It is used both for the system-wide message bus service, and as a per-user-login-session messaging facility." \
      \
      org.label-schema.schema-version="1.0" \
      org.label-schema.license="(GPL-2.0+ or AFL-2.1) and GPL-2.0+" \
      org.label-schema.url="https://github.com/NicolasT/contained-ganesha" \
      org.label-schema.vcs-url="https://github.com/NicolasT/contained-ganesha.git" \
      org.label-schema.vendor="Nicolas Trangez <https://nicolast.be>" \
      org.label-schema.name="dbus-daemon" \
      org.label-schema.description="D-BUS is a system for sending messages between applications. It is used both for the system-wide message bus service, and as a per-user-login-session messaging facility." \
      org.label-schema.usage="https://github.com/NicolasT/contained-ganesha/blob/master/images/dbus-daemon/README.md" \
      org.label-schema.docker.params="" \
      org.label-schema.docker.cmd="docker run -d --cap-drop ALL --cap-add SETGID --cap-add SETPCAP --cap-add SETUID --read-only --tmpfs /run/dbus --tmpfs /var/lib/dbus contained-ganesha/dbus-daemon" \
      org.label-schema.docker.cmd.debug="docker exec -it \$CONTAINER /bin/bash" \
      \
      app.kubernetes.io/name="dbus-daemon" \
      app.kubernetes.io/component="system-bus" \
      app.kubernetes.io/part-of="contained-ganesha"
