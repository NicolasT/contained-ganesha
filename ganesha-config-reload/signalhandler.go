package main

import (
	"context"
	"os"
	"os/signal"

	"github.com/go-logr/logr"
)

type signalHandler struct {
	cancel context.CancelFunc
	log    logr.Logger
	sigs   []os.Signal
	c      chan os.Signal
}

func NewSignalHandler(log logr.Logger, cancel context.CancelFunc, sigs ...os.Signal) (*signalHandler, error) {
	return &signalHandler{
		cancel: cancel,
		log:    log,
		sigs:   sigs,
		c:      make(chan os.Signal, 1),
	}, nil
}

func (s *signalHandler) Register() error {
	s.log.V(0).Info("Registering signal handler")
	signal.Notify(s.c, s.sigs...)
	return nil
}

func (s *signalHandler) Run(ctx context.Context) error {
	defer signal.Stop(s.c)

	s.log.V(1).Info("Waiting for events")

	select {
	case sig := <-s.c:
		s.log.V(0).Info("Received signal, canceling context", "signal", sig)
		s.cancel()
	case <-ctx.Done():
		s.log.V(1).Info("Context done")
	}

	return nil
}

func (s *signalHandler) Close() {
	s.log.V(0).Info("Resetting signal handlers")
	signal.Reset(s.sigs...)
}
