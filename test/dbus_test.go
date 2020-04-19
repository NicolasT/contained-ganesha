package test

import (
	"testing"

	//"github.com/godbus/dbus/v5"
)

func TestDbus(t *testing.T) {
/*
	err := waitForSocket(Context, "unix", "/run/dbus/system_bus_socket")
	if err != nil {
		t.Fatalf("Error waiting for DBus: %v", err)
	}

	conn, err := dbus.SystemBus()
	if err != nil {
		t.Fatalf("Unable to connect to DBus system bus: %v", err)
	}
	defer conn.Close()

	var id string
	err = conn.BusObject().CallWithContext(Context, "org.freedesktop.DBus.GetId", 0).Store(&id)
	if err != nil {
		t.Errorf("Error while calling GetId: %v", err)
	}
*/
}
