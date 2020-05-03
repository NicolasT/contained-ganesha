package main

import (
	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

var _ = Describe("watchMode", func() {
	Context("when parsed as a flag", func() {
		It("should parse 'configmap' into WatchModeConfigMap", func() {
			var w watchMode
			Expect(w.Set("configmap")).To(Succeed())
			Expect(w).To(Equal(WatchModeConfigMap))
		})

		It("should parse 'file' into WatchModeFile", func() {
			var w watchMode
			Expect(w.Set("file")).To(Succeed())
			Expect(w).To(Equal(WatchModeFile))
		})

		It("should fail on other values", func() {
			var w watchMode
			Expect(w.Set("other")).NotTo(Succeed())
		})
	})

	Context("when turned into a string", func() {
		It("turns WatchModeConfigMap into 'configmap'", func() {
			w := WatchModeConfigMap
			Expect(w.String()).To(Equal("configmap"))
		})

		It("turns WatchModeFile into 'file'", func() {
			w := WatchModeFile
			Expect(w.String()).To(Equal("file"))
		})
	})
})
