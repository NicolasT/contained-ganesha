package test

import (
	"context"
	"net"
	"testing"
	"time"

	"github.com/vmware/go-nfs-client/nfs/rpc"
)

func WaitForSocket(ctx context.Context, proto string, address string) error {
	d := net.Dialer{}

	for {
		conn, err := d.DialContext(ctx, proto, address)
		if err != nil {
			ctxErr := ctx.Err()
			if ctxErr != nil {
				return err
			}

			time.Sleep(500 * time.Millisecond)
			continue
		}
		defer conn.Close()
		break
	}

	return nil
}

type Mapping struct {
	Name string
	Prot uint32
	Vers uint32
}

func PortmapTestHelper(t *testing.T, host string, prog uint32, mappings []Mapping, expectedPort int) {
	pm, err := rpc.DialPortmapper("tcp", host)
	if err != nil {
		t.Fatalf("Unable to dial portmapper service: %v", err)
	}

	for _, tc := range mappings {
		tc := tc
		t.Run(tc.Name, func(t *testing.T) {
			port, err := pm.Getport(rpc.Mapping{
				Prog: prog,
				Vers: tc.Vers,
				Prot: tc.Prot,
			})
			if err != nil {
				t.Fatalf("Unable to get port: %v", err)
			}

			if port != expectedPort {
				t.Errorf("Unexpected port, got %d, want %d", port, expectedPort)
			}
		})
	}
}
