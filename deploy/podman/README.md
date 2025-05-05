contained-ganesha on Podman
===========================
Deploy `contained-ganesha` using [podman](https://podman.io), using `podman
play kube`.

Note: `podman play kube` won't work as-is, so wrappers using `make` are
provided.

Getting Started
---------------
The easiest way to get started is to run `make up-local`, which will build the
required container images locally, render the manifest file, then run the
containers in a `podman` `Pod` using the local images.

To render the manifest file only, run `make manifest`.

The default configuration will export an in-memory filesystem (the `mem` FSAL)
as `/mem`.

Eventually, `make down` will bring down the environment like
`podman play kube --down` does.

Tests
-----
Run `make check` to run a test-suite in a deployed environment.

Design
------
This deployment runs all containers in a `Pod` and launches this using
`podman play kube`. The `nfs-ganesha` configuration is deployed using
a `ConfigMap`.
