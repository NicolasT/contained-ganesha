package main_test

import (
	"context"
	"log"
	"os"
	"sync"
	"syscall"

	"github.com/go-logr/logr"
	"github.com/go-logr/stdr"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "github.com/NicolasT/contained-ganesha/ganesha-config-reload"
)

var _ = Describe("signalHandler", func() {
	var (
		logger logr.Logger
	)

	BeforeEach(func() {
		logger = stdr.New(log.New(GinkgoWriter, "", log.LstdFlags))
	})

	Context("when handling a single signal", func() {
		It("cancels a context when signaled", func(done Done) {
			ctx, cancel := context.WithCancel(context.Background())
			defer cancel()

			By("Setting up a signal handler")
			s, err := NewSignalHandler(logger, cancel, syscall.SIGUSR1)
			Expect(err).NotTo(HaveOccurred())
			defer func() {
				// Ensure signal handlers are reset *before* signaling end-of-test
				s.Close()
				close(done)
			}()
			err = s.Register()
			Expect(err).NotTo(HaveOccurred())

			By("Launching the signal handler")
			wg := &sync.WaitGroup{}
			wg.Add(1)
			go func() {
				defer GinkgoRecover()
				defer wg.Done()
				err := s.Run(ctx)
				if err != nil {
					logger.Error(err, "Error in signal handler")
				}
			}()

			By("Sending the signal")
			proc, err := os.FindProcess(os.Getpid())
			Expect(err).NotTo(HaveOccurred())
			err = proc.Signal(syscall.SIGUSR1)
			Expect(err).NotTo(HaveOccurred())

			By("Waiting for the signal handler to return")
			wg.Wait()

			Expect(ctx.Done()).To(BeClosed())
		})
	})
})
