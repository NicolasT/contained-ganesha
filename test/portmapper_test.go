package test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/vmware/go-nfs-client/nfs/rpc"
)

func TestPortmap(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	err := WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, PortmapperPort))
	if err != nil {
		t.Fatalf("Portmap service not available: %v", err)
	}

	tests := []Mapping{
		{
			Name: "v2/TCP",
			Prot: rpc.IPProtoTCP,
			Vers: 2,
		},
		{
			Name: "v2/UDP",
			Prot: rpc.IPProtoUDP,
			Vers: 2,
		},
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
		{
			Name: "v4/UDP",
			Prot: rpc.IPProtoUDP,
			Vers: 4,
		},
	}

	PortmapTestHelper(t, Host, rpc.PmapProg, tests, PortmapperPort)
}
