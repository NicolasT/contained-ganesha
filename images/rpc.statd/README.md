rpc.statd
---------
This container image will run the [rpc.statd](http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=summary) *NLM status* daemon.

Volumes
-------
| Path           | Type       | Description                                                  |
| ----           | ----       | -----------                                                  |
| */run*         | bind       | Directory where `rpcbind.sock` resides (see *rpcbind* image) |
| */var/lib/nfs* | persistent | Service state directory                                      |

Ports
-----
| Port | Protocol | Description      |
| ---- | -------- | -----------      |
| 865  | TCP      | *status* service |
| 865  | UDP      | *status* service |

Environment
-----------
| Name          | Default | Description                              |
| ----          | ------- | -----------                              |
| *STATUS_PORT* | 865     | Port for the *status* service to bind to |
