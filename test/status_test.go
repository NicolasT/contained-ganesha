package test

import (
	"context"
	"fmt"
	"testing"

	"github.com/vmware/go-nfs-client/nfs/rpc"
)

func TestStatus(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), Timeout)
	defer cancel()

	err := WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, PortmapperPort))
	if err != nil {
		t.Fatalf("Portmap service not available: %v", err)
	}
	err = WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, StatusPort))
	if err != nil {
		t.Fatalf("Status service not available: %v", err)
	}

	tests := []Mapping{
		{
			Name: "v1/TCP",
			Prot: rpc.IPProtoTCP,
			Vers: 1,
		},
		{
			Name: "v1/UDP",
			Prot: rpc.IPProtoUDP,
			Vers: 1,
		},
	}

	PortmapTestHelper(t, Host, 100024, tests, StatusPort)
}
