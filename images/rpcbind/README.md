rpcbind
=======
This container image will run the [rpcbind](http://git.linux-nfs.org/?p=steved/rpcbind.git;a=summary) *portmapper* daemon.

Volumes
-------
| Path   | Type  | Description                                       |
| ----   | ----  | -----------                                       |
| */run* | tmpfs | Directory in which `rpcbind.sock` will be created |

Ports
-----
| Port                | Protocol | Description          |
| ----                | -------- | -----------          |
| 111                 | TCP      | *portmapper* service |
| 111                 | UDP      | *portmapper* service |
| */run/rpcbind.sock* | unix     | *portmapper* service |
