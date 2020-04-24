contained-ganesha
=================
[NFS-Ganesha](https://nfs-ganesha.github.io) running in container environments. Properly.

This repository contains Docker container image build files for all services
requird to run an NFS-Ganesha server in a containerized environment, as well
as deployment files for the following container environments:

- [docker-compose](https://docs.docker.com/compose/)
- [Kubernetes](https://kubernetes.io)

To build the container images, run `make containers`. See `deploy/` for more
information on the supported deployment mechanisms.

Rationale
---------
An NFS server requires several services to be running (at least to support
NFS3):

- A *portmapper* daemon (`rpcbin`)
- An NLM status daemon (`rpc.statd`)
- In case of NFS-Ganesha, `dbus-daemon` for configuration
- The NFS server, which in case of NFS-Ganesha includes `mountd`, `nlockmgr`
  and `ruotad`

Some projects provide a Docker container image which includes and starts all
these services in a single container. This goes against the principes of
containerized deployments, where a single container should ideally run only a
single service, and each container image should only contain the files required
to run this service.

As such, this projects provides 4 container images (one for each service), and
runs all of them in a single Pod (think 'network namespace'), which is a
standard concept in Kubernetes, or emulated when using `docker-compose` (see
the design section in the documentation).

The container images apply as much sharing of layers as possible (by
construction of the various `Dockerfile`s). They each contain a healthcheck
script.

Security
--------
Service deployment using containers can increase security of the system, e.g.,
by restricting the *capabilities* of a containerized process. The services
deployed by this project are confined using the following mechanisms:

- The container image (root filesystem) is made read-only. Locations where the
  services require write access are mounted as a volume (either *tmpfs* or
  persistent).
- All Linux *capabilities* are dropped by default (`--cap-drop ALL` or
  similar). Required capabilities are added when needed.
- Services run as non-root user, where possible. However, this is (for now) not
  enforced by the container engine: the services start as `root`, then `setuid`
  and `setgid` themselves.
- When using `docker-compose`, the `dbus-daemon` container is not connected to
  the network, since this is not required.
