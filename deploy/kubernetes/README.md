contained-ganesha on Kubernetes
===============================
Deploy `contained-ganesha` using [Kubernetes](https://kubernetes.io).

Getting Started
---------------
First, generate the Kubernetes manifest files by running `make manifests`.

The manifests use [Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/).
To deploy the service in your cluster using remote images, run
`kubectl apply -k ./base`. However, this is likely not to work, since pulling
the default images requires authentication. Instead, publish them somewhere,
then create a Kustomize 'overlay' to point at them. Use the `local` overlay
for inspiration.

Alternatively, if the local images are accessible from your cluster, run
`make kubectl-local-apply` (and later, `make kubectl-local-delete`).

Using Kind
----------
When using a [Kind](https://kind.sigs.k8s.io/) cluster, run
`make kind-load-docker-images` to build all container images and load them
into your Kind cluster. Then, `make kubectl-local-apply` will work.

Tests
-----
Run `make check` to run a test-suite against a deployed environment.
This implies the services must be previously deployed in your cluster.

The tests require the `contained-ganesha-test` image to be available.
Again, when using Kind, run `make kind-load-cgt-image` to build and load this
test image.
