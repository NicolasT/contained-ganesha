package test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/vmware/go-nfs-client/nfs/rpc"
)

func TestNlockmgr(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	err := WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, PortmapperPort))
	if err != nil {
		t.Fatalf("Portmap service not available: %v", err)
	}
	err = WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, NlockmgrPort))
	if err != nil {
		t.Fatalf("Nlockmgr service not available: %v", err)
	}

	tests := []Mapping{
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

	PortmapTestHelper(t, Host, 100021, tests, NlockmgrPort)
}
