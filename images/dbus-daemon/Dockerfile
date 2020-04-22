FROM docker.io/centos:8

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
