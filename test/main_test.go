package test

import (
	"flag"
	"os"
	"testing"
	"time"

	"github.com/vmware/go-nfs-client/nfs/util"
)

var (
	Host           string
	PortmapperPort int
	StatusPort     int
	NlockmgrPort   int
	RquotadPort    int
	NfsPort        int
	MountdPort     int

	timeoutS int
	Timeout  time.Duration
)

func init() {
	flag.StringVar(&Host, "host", "127.0.0.1", "host against which to run the tests")
	flag.IntVar(&PortmapperPort, "portmapper-port", 111, "port of the portmapper service")
	flag.IntVar(&StatusPort, "status-port", 865, "poprt of the status service")
	flag.IntVar(&NlockmgrPort, "nlockmgr-port", 866, "port of the nlockmgr service")
	flag.IntVar(&RquotadPort, "rquotad-port", 875, "port of the rquotad service")
	flag.IntVar(&NfsPort, "nfs-port", 2049, "port of the NFS service")
	flag.IntVar(&MountdPort, "mountd-port", 20048, "port of the mountd service")
	flag.IntVar(&timeoutS, "service-timeout", 120, "timeout to wait for services to appear")
}

func TestMain(m *testing.M) {
	flag.Parse()

	Timeout = time.Duration(timeoutS) * time.Second

	util.DefaultLogger.SetDebug(testing.Verbose())

	os.Exit(m.Run())
}
