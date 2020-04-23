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
