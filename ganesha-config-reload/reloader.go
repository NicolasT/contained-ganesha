package main

import (
	"context"
	"errors"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/go-logr/logr"
)

type reloader struct {
	log     logr.Logger
	pidFile string
	events  chan interface{}
	signal  os.Signal
	act     bool
	ticker  *time.Ticker
}

func NewReloader(log logr.Logger, events chan interface{}, pidFile string, signal os.Signal) *reloader {
	return &reloader{
		log:     log.WithValues("pidfile", pidFile),
		events:  events,
		pidFile: pidFile,
		signal:  signal,
		act:     false,
		ticker:  time.NewTicker(time.Second),
	}
}

func (r *reloader) Run(ctx context.Context) error {
	lastEventWasTick := false

	for {
		// Don't spam logs with loop iterations caused by the ticker
		if !lastEventWasTick {
			r.log.V(1).Info("Waiting for events")
		}
		lastEventWasTick = false

		select {
		case _, ok := <-r.events:
			if !ok {
				r.log.Info("Events channel closed")
				return nil
			}

			r.log.Info("Detected configuration change")
			r.act = true

		case _, ok := <-r.ticker.C:
			lastEventWasTick = true

			if !ok {
				r.log.Info("Ticker stopped")
				return errors.New("Ticker channel stopped unexpectedly")
			}

			if r.act {
				r.act = false

				r.log.Info("Tick with configuration change, triggering reload")
				if err := r.reload(); err != nil {
					r.log.Error(err, "Error while triggering reload")
					return err
				}
			}

		case <-ctx.Done():
			r.log.V(1).Info("Context done")
			return nil
		}
	}
}

func (r *reloader) reload() error {
	dat, err := ioutil.ReadFile(r.pidFile)
	if err != nil {
		r.log.Error(err, "Failed to read Ganesha PID file")
		return err
	}
	str := strings.TrimSuffix(string(dat[:]), "\n")
	pid, err := strconv.ParseUint(str, 10, 64)
	if err != nil {
		r.log.Error(err, "Failed to parse Ganesha PID", "data", dat)
		return err
	}
	pid2 := int(pid)

	proc, err := os.FindProcess(pid2)
	if err != nil {
		r.log.Error(err, "Failed to find process", "pid", pid2)
		return err
	}

	err = proc.Signal(r.signal)
	if err != nil {
		r.log.Error(err, "Failed to signal process", "pid", pid2, "signal", r.signal)
		return err
	}
	r.log.Info("Sent signal to process", "pid", pid2, "signal", r.signal)

	return nil
}

func (r *reloader) Close() {
	r.ticker.Stop()
}
