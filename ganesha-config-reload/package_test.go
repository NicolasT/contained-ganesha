package main_test

import (
	"testing"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
)

func TestGaneshaConfigReload(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "ganesha-config-reload")
}
