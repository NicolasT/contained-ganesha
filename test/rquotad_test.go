package test

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/vmware/go-nfs-client/nfs/rpc"
)

func TestRquotad(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	err := WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, PortmapperPort))
	if err != nil {
		t.Fatalf("Portmap service not available: %v", err)
	}
	err = WaitForSocket(ctx, "tcp", fmt.Sprintf("%s:%d", Host, RquotadPort))
	if err != nil {
		t.Fatalf("Rquotad service not available: %v", err)
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
	}

	PortmapTestHelper(t, Host, 100011, tests, RquotadPort)
}
