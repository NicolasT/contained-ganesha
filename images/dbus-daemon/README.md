dbus-daemon
===========
This container image will run a [DBus](https://freedesktop.org/wiki/Software/dbus) daemon.
The default `CMD` will run a systemwide message bus.

Volumes
-------
| Path            | Type       | Description                                                  |
| ----            | ----       | -----------                                                  |
| */run/dbus*     | tmpfs      | Directory in which the bus socket will be created            |
| */var/lib/dbus* | persistent | Directory in which the generated machine UUID will be stored |

Ports
-----
| Port                          | Protocol | Description            |
| ----                          | -------- | -----------            |
| */run/dbus/system_bus_socket* | unix     | DBus system bus socket |
