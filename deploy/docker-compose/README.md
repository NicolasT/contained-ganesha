contained-ganesha on docker-compose
===================================
Deploy `contained-ganesha` using [docker-compose](https://docs.docker.com/compose/).

Note: `docker-compose up` won't work as-is, so wrappers using `make` are
provided. Alternatively, setting the required environment variables or passing
the path to a suitable `.env` file would work.

Getting Started
---------------
The easiest way to get started is to run `make up-local`, which will build the
required container images locally, then run the containers using these images.

To access the NFS server (e.g., using `rpcinfo` and `showmount` for initial
testing), run `make show-ip`.

The default configuration will export an in-memory filesystem (the `mem` FSAL)
as `/mem`.

Eventually, `make down` will bring down the environment like
`docker-compose down` does.

Tests
-----
Run `make check` to run a test-suite in a deployed environment.

Design
------
This deployment includes a `pod` container which runs the `pause` image as used
in Kubernetes Pods. After start, this container is used as the keeper of a
network namespace which is then shared (using Docker's
`--network "service:pod"` feature) by all other containers (except for
`dbus-daemon` which doesn't require network access), so all services appear to
run on the same host, as is intended between `rpcbind`, `rpc.statd` and
`nfs-ganesha`.

The `dbus-daemon` and `nfs-ganesha` containers interact through a shared
`tmpfs` volume mounted at `/run/dbus`.
