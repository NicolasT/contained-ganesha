package main_test

import (
	"context"
	"io/ioutil"
	"log"
	"os"
	"sync"

	"k8s.io/kubernetes/pkg/volume/util"

	"github.com/fsnotify/fsnotify"
	"github.com/go-logr/logr"
	"github.com/go-logr/stdr"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	. "github.com/NicolasT/contained-ganesha/ganesha-config-reload"
)

var _ = Describe("Watcher", func() {
	var (
		logger     logr.Logger
		configPath string
	)

	BeforeEach(func() {
		logger = stdr.New(log.New(GinkgoWriter, "", log.LstdFlags))

		By("Creating a temporary directory")
		var err error
		configPath, err = ioutil.TempDir("", "ganesha-config-reload-test")
		Expect(err).NotTo(HaveOccurred())
	})

	AfterEach(func() {
		By("Cleaning up the temporary directory")
		os.RemoveAll(configPath)
	})

	Context("when used with a ConfigMap", func() {
		payload1 := map[string]util.FileProjection{
			"local.conf": util.FileProjection{
				Data: []byte{},
				Mode: 0400,
			},
			"exports.conf": util.FileProjection{
				Data: []byte{},
				Mode: 0400,
			},
		}

		payload2 := map[string]util.FileProjection{
			"local.conf": util.FileProjection{
				Data: []byte{},
				Mode: 0400,
			},
			"exports.conf": util.FileProjection{
				Data: []byte{'a', 'b', 'c'},
				Mode: 0400,
			},
		}

		It("emits an event as expected", func(done Done) {
			aw, err := util.NewAtomicWriter(configPath, "gcr-test")
			Expect(err).NotTo(HaveOccurred())

			By("Creating a first version of the ConfigMap")
			Expect(aw.Write(payload1, nil)).To(Succeed())

			By("Constructing a watcher")
			w, err := NewWatcher(logger, ConfigMapChecker, []string{configPath})
			Expect(err).NotTo(HaveOccurred())
			defer w.Close()

			By("Registering the watcher")
			Expect(w.Register()).To(Succeed())

			By("Running the watcher")
			ctx, cancel := context.WithCancel(context.Background())

			wg := &sync.WaitGroup{}
			wg.Add(1)
			go func() {
				defer GinkgoRecover()
				defer wg.Done()
				Expect(w.Run(ctx)).To(Succeed())
			}()

			By("Replacing the ConfigMap content")
			Expect(aw.Write(payload2, nil)).To(Succeed())

			By("Waiting for an event to trigger")
			Eventually(w.Events).Should(Receive())

			By("Waiting for everything to clean up")
			cancel()
			wg.Wait()

			close(done)
		})
	})
})

var _ = Describe("ConfigMapChecker", func() {
	It("returns 'true' when creating '..data'", func() {
		evt := fsnotify.Event{
			Name: "..data",
			Op:   fsnotify.Create,
		}
		Expect(ConfigMapChecker(evt)).To(BeTrue())
	})

	It("returns 'true' when '..data' is prefixed", func() {
		evt := fsnotify.Event{
			Name: "config/..data",
			Op:   fsnotify.Create,
		}
		Expect(ConfigMapChecker(evt)).To(BeTrue())
	})

	It("returns 'true' when Create is only one of the operations", func() {
		evt := fsnotify.Event{
			Name: "..data",
			Op:   fsnotify.Create | fsnotify.Chmod,
		}
		Expect(ConfigMapChecker(evt)).To(BeTrue())
	})

	It("returns 'false' when another name is created", func() {
		evt := fsnotify.Event{
			Name: ".data",
			Op:   fsnotify.Create,
		}
		Expect(ConfigMapChecker(evt)).To(BeFalse())
	})
})

var _ = Describe("FileChecker", func() {
	It("returns 'true' when creating a file", func() {
		evt := fsnotify.Event{
			Name: "exports.conf",
			Op:   fsnotify.Create,
		}
		Expect(FileChecker(evt)).To(BeTrue())
	})

	It("returns 'true' when writing to a file", func() {
		evt := fsnotify.Event{
			Name: "exports.conf",
			Op:   fsnotify.Write,
		}
		Expect(FileChecker(evt)).To(BeTrue())
	})
})
