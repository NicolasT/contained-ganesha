package main_test

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/signal"
	"sync"
	"syscall"

	"github.com/go-logr/logr"
	"github.com/go-logr/stdr"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "github.com/NicolasT/contained-ganesha/ganesha-config-reload"
)

var _ = Describe("reloader", func() {
	var (
		logger  logr.Logger
		pidFile string
	)

	BeforeEach(func() {
		logger = stdr.New(log.New(GinkgoWriter, "", log.LstdFlags))

		fh, err := ioutil.TempFile("", "gcr-test.pid")
		Expect(err).NotTo(HaveOccurred())
		pidFile = fh.Name()
		Expect(fh.Close()).To(Succeed())

		data := []byte(fmt.Sprintf("%d\n", os.Getpid()))
		Expect(ioutil.WriteFile(pidFile, data, 0600)).To(Succeed())
	})

	AfterEach(func() {
		Expect(os.Remove(pidFile)).To(Succeed())
	})

	It("sends a signal upon trigger, eventually", func(done Done) {
		By("Setting up a signal handler")
		usr1 := syscall.SIGUSR1
		sig := make(chan os.Signal, 1)
		defer close(sig)

		signal.Notify(sig, usr1)
		defer func() {
			// Ensure signal handlers are reset *before* signaling 'done'
			signal.Stop(sig)
			signal.Reset(usr1)
			close(done)
		}()

		By("Creating a reloader")
		c := make(chan interface{})
		defer close(c)
		r := NewReloader(logger, c, pidFile, usr1)
		defer r.Close()

		By("Running the reloader")
		ctx, cancel := context.WithCancel(context.Background())
		defer cancel()

		wg := &sync.WaitGroup{}
		wg.Add(1)
		go func() {
			defer GinkgoRecover()
			defer wg.Done()
			Expect(r.Run(ctx)).To(Succeed())
		}()

		By("Triggering a reload")
		c <- nil

		By("Waiting for a signal to be received")
		Eventually(sig, 1.5 /* Reloader dampens events to 1/s */).Should(Receive())

		By("Waiting for everything to be cleaned up")
		cancel()
		wg.Wait()
	}, 2 /* Reloader dampens events to 1/s */)
})
