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
