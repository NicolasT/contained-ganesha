ganesha-config-reload
=====================
The `ganesha-config-reload` sidecar detects configuration file updates and
sends the config reload signal (`SIGHUP`) to the NFS-Ganesha process to
reload its settings.

Volumes
-------
| Path                                       | Type | Description                                                              |
| ----                                       | ---- | -----------                                                              |
| */run/ganesha/ganesha.pid*                 | bind | NFS-Ganesha PID-file                                                     |
| */etc/ganesha/ganesha.conf.d*              | bind | NFS-Ganesha configuration files (monitored in Kubernetes ConfigMap mode) |
