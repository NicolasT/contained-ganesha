package test

import (
	"context"
	//"fmt"
	"log"
	"net"
	"os"
	"strconv"
	"testing"
	"time"

	"github.com/vmware/go-nfs-client/nfs/rpc"
	//"github.com/vmware/go-nfs-client/nfs/util"

	"github.com/godbus/dbus/v5"
)

const (
	host = "127.0.0.1"
	statusProg = 100024
	nlockmgrProg = 100021
	rquotadProg = 100011
	nfsProg = 100003
	mountdProg = 100005
)

var (
	portmapperPort = 0
	statusPort = 0
	nlockmgrPort = 0
	rquotadPort = 0
	nfsPort = 0
	mountdPort = 0
)

/*
func TestMain(m *testing.M) {
	ctx := context.Background()

	portmapperPort = getPort("PORTMAPPER_PORT")
	statusPort = getPort("STATUS_PORT")
	nlockmgrPort = getPort("NLOCKMGR_PORT")
	rquotadPort = getPort("RQUOTAD_PORT")
	nfsPort = getPort("NFS_PORT")
	mountdPort = getPort("MOUNTD_PORT")

	err := waitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", host, portmapperPort))
	if err != nil {
		log.Fatalf("Error waiting for rpcbind: %v", err)
	}

	err = waitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", host, statusPort))
	if err != nil {
		log.Fatalf("Error waiting for rpc.statd: %v", err)
	}

	err = waitForSocket(ctx, "unix", "/run/dbus/system_bus_socket")
	if err != nil {
		log.Fatalf("Error waiting for DBus: %v", err)
	}

	err = waitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", host, nfsPort))
	if err != nil {
		log.Fatalf("Error waithing for NFS: %v", err)
	}

	util.DefaultLogger.SetDebug(true)

	os.Exit(m.Run())
}
*/
func getPort(name string) int {
	val := os.Getenv(name)
	if val == "" {
		log.Fatalf("No value set for %s", name)
	}

	i, err := strconv.ParseInt(val, 10, 16); if err != nil {
		log.Fatalf("Unable to parse %s: %v", name, err)
	}

	return int(i)
}

func waitForSocket(ctx context.Context, proto string, address string) error {
	timeout := 10 * time.Second
	ctx, cancel := context.WithTimeout(ctx, timeout)
	defer cancel()

	d := net.Dialer{}

	for {
		conn, err := d.DialContext(ctx, proto, address)
		if err != nil {
			ctxErr := ctx.Err(); if ctxErr != nil {
				log.Printf("Context error: %s", ctxErr.Error())
				return err
			}

			if neterr, ok := err.(net.Error); ok {
				if neterr.Temporary() {
					log.Printf("Temporary error (retrying): %s", neterr.Error())
				} else {
					log.Printf("Non-temporary error (retrying): %s", neterr.Error())
				}
				time.Sleep(500 * time.Millisecond)
				continue
			} else {
				return err
			}
		}
		defer conn.Close()
		break
	}

	return nil
}

type prog struct {
	name string
	prot uint32
	vers uint32
}

func testPortmap(t *testing.T, prog uint32, progs []prog, expectedPort int) {
	pm, err := rpc.DialPortmapper("tcp", host); if err != nil {
		t.Fatalf("Unable to dial portmapper service: %v", err)
	}

	for _, tc := range progs {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			port, err := pm.Getport(rpc.Mapping{
				Prog: prog,
				Vers: tc.vers,
				Prot: tc.prot,
			})
			if err != nil {
				t.Fatalf("Unable to get port: %v", err)
			}

			log.Printf("foo %d %d", port, expectedPort)
			if port != expectedPort {
				t.Errorf("Unexpected port, got %d, want %d", port, expectedPort)
			}
		})
	}
}

func TestPortmap(t *testing.T) {
	tests := []prog {
		{
			name: "v2/TCP",
			prot: rpc.IPProtoTCP,
			vers: 2,
		},
		{
			name: "v2/UDP",
			prot: rpc.IPProtoUDP,
			vers: 2,
		},
		{
			name: "v3/TCP",
			prot: rpc.IPProtoTCP,
			vers: 3,
		},
		{
			name: "v3/UDP",
			prot: rpc.IPProtoUDP,
			vers: 3,
		},
		{
			name: "v4/TCP",
			prot: rpc.IPProtoTCP,
			vers: 4,
		},
		{
			name: "v4/UDP",
			prot: rpc.IPProtoUDP,
			vers: 4,
		},
	}

	testPortmap(t, rpc.PmapProg, tests, rpc.PmapPort)
}

func TestStatus(t *testing.T) {
	tests := []prog {
		{
			name: "v1/TCP",
			prot: rpc.IPProtoTCP,
			vers: 1,
		},
		{
			name: "v1/UDP",
			prot: rpc.IPProtoUDP,
			vers: 1,
		},
	}

	testPortmap(t, statusProg, tests, statusPort)
}

func TestDBus(t *testing.T) {
	conn, err := dbus.SystemBus()
	if err != nil {
		t.Fatalf("Unable to connect to DBus system bus: %v", err)
	}
	defer conn.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 5 * time.Second)
	defer cancel()

	var id string
	err = conn.BusObject().CallWithContext(ctx, "org.freedesktop.DBus.GetId", 0).Store(&id)
	if err != nil {
		t.Errorf("Error while calling GetId: %v", err)
	}
}

func TestNlockmgr(t *testing.T) {
	tests := []prog {
		{
			name: "v4/TCP",
			prot: rpc.IPProtoTCP,
			vers: 4,
		},
		{
			name: "v4/UDP",
			prot: rpc.IPProtoUDP,
			vers: 4,
		},
	}

	testPortmap(t, nlockmgrProg, tests, nlockmgrPort)
}

func TestRquotad(t *testing.T) {
	tests := []prog {
		{
			name: "v1/TCP",
			prot: rpc.IPProtoTCP,
			vers: 1,
		},
		{
			name: "v1/UDP",
			prot: rpc.IPProtoUDP,
			vers: 1,
		},
		{
			name: "v2/TCP",
			prot: rpc.IPProtoTCP,
			vers: 2,
		},
		{
			name: "v2/UDP",
			prot: rpc.IPProtoUDP,
			vers: 2,
		},
	}

	testPortmap(t, rquotadProg, tests, rquotadPort)

}

func TestNFS(t *testing.T) {
	tests := []prog {
		{
			name: "v3/TCP",
			prot: rpc.IPProtoTCP,
			vers: 3,
		},
		{
			name: "v3/UDP",
			prot: rpc.IPProtoUDP,
			vers: 3,
		},
		{
			name: "v4/TCP",
			prot: rpc.IPProtoTCP,
			vers: 4,
		},
		{
			name: "v4/UDP",
			prot: rpc.IPProtoUDP,
			vers: 4,
		},
	}

	testPortmap(t, nfsProg, tests, nfsPort)

}

func TestMountd(t *testing.T) {
	tests := []prog {
		{
			name: "v1/TCP",
			prot: rpc.IPProtoTCP,
			vers: 1,
		},
		{
			name: "v1/UDP",
			prot: rpc.IPProtoUDP,
			vers: 1,
		},
		{
			name: "v3/TCP",
			prot: rpc.IPProtoTCP,
			vers: 3,
		},
		{
			name: "v3/UDP",
			prot: rpc.IPProtoUDP,
			vers: 3,
		},
	}

	testPortmap(t, mountdProg, tests, mountdPort)

}
