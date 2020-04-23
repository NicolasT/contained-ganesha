package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/vmware/go-nfs-client/nfs"
	"github.com/vmware/go-nfs-client/nfs/rpc"
)

func TestNfs(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), Timeout)
	defer cancel()

	err := WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, PortmapperPort))
	if err != nil {
		t.Fatalf("Portmap service not available: %v", err)
	}
	err = WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, NfsPort))
	if err != nil {
		t.Fatalf("NFS service not available: %v", err)
	}

	tests := []Mapping{
		{
			Name: "v3/TCP",
			Prot: rpc.IPProtoTCP,
			Vers: 3,
		},
		{
			Name: "v3/UDP",
			Prot: rpc.IPProtoUDP,
			Vers: 3,
		},
		{
			Name: "v4/TCP",
			Prot: rpc.IPProtoTCP,
			Vers: 4,
		},
	}

	PortmapTestHelper(t, Host, 100003, tests, NfsPort)

	t.Run("ops", testOps)
}

func testOps(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), Timeout)
	defer cancel()

	err := WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, MountdPort))
	if err != nil {
		t.Fatalf("Mount service not available: %v", err)
	}

	mount, err := nfs.DialMount(Host)
	if err != nil {
		t.Fatalf("Unable to dial mount: %v", err)
	}
	defer mount.Close()

	auth := rpc.NewAuthUnix("testsuite", 1234, 1234)

	fs, err := mount.Mount("/mem", auth.Auth())
	if err != nil {
		t.Fatalf("Unable to mount: %v", err)
	}
	defer fs.Close()

	_, err = fs.ReadDirPlus(".")
	if err != nil {
		t.Errorf("ReadDirPlus failed: %v", err)
	}
}
