nfs-ganesha
===========
This container image will run the [nfs-ganesha](http://nfs-ganesha.github.io/) NFS server.

Volumes
-------
| Path                                       | Type       | Description                                                                                                                                                          |
| ----                                       | ----       | -----------                                                                                                                                                          |
| */tmp*                                     | tmpfs      | Temporary storage                                                                                                                                                    |
| */run*                                     | bind       | Directory where `rpcbind.sock` resides (see *rpcbind* image)                                                                                                         |
| */run/dbus*                                | bind       | Directory where *system_bus_socket* resides (see *dbus-daemon* image)                                                                                                |
| */var/lib/nfs/ganesha*                     | persistent | Service state directory                                                                                                                                              |
| */etc/ganesha/ganesha.conf.d/local.conf*   | bind       | File included in main configuration, for overrides                                                                                                                   |
| */etc/ganesha/ganesha.conf.d/exports.conf* | bind       | File included in main configuration, for export definitions                                                                                                          |
| */etc/ganesha/ganesha.conf*                | bind       | Optional configuration file. If provided, the configuration files above won't be used                                                                                |
| */etc/ganesha/ganesha.conf.sh*             | bind       | Optional configuration script to generate configuration. Not used when `/etc/ganesha/ganesha.conf` exists. If provided, the configuration files above won't be used. |

Ports
-----
| Port  | Protocol | Description        |
| ----  | -------- | -----------        |
| 866   | TCP      | *nlockmgr* service |
| 866   | UDP      | *nlockmgr* service |
| 875   | TCP      | *rquotad* service  |
| 875   | UDP      | *rquotad* service  |
| 2049  | TCP      | NFS service        |
| 2049  | UDP      | NFS service        |
| 20048 | TCP      | *mountd* service   |
| 20048 | UDP      | *mountd* service   |

Environment
-----------
| Name            | Default | Description                                |
| ----            | ------- | -----------                                |
| *MOUNTD_PORT*   | 20048   | Port for the *mountd* service to bind to   |
| *NFS_PORT*      | 2049    | Port for the NFS service to bind to        |
| *NLOCKMGR_PORT* | 866     | Port for the *nlockmgr* service to bind to |
| *RQUOTAD_PORT*  | 875     | Port for the *rquotad* service to bind to  |
