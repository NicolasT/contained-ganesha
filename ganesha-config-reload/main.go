package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"syscall"

	"golang.org/x/sync/errgroup"

	zap "sigs.k8s.io/controller-runtime/pkg/log/zap"
)

const (
	defaultPidFile = "/run/ganesha/ganesha.pid"
	defaultSignal  = syscall.SIGHUP
)

var (
	pidFile string
	mode    watchMode
	logOpts zap.Options
)

func init() {
	flag.StringVar(&pidFile, "pid", defaultPidFile, "path of the NFS-Ganesha PID file")
	flag.Var(&mode, "mode", "watch mode ('configmap' or 'file')")
	err := flag.Set("mode", "file")
	if err != nil {
		panic("Unable to set mode flag default value")
	}
	logOpts.BindFlags(flag.CommandLine)
}

func main() {
	flag.Parse()
	if flag.NArg() < 1 {
		fmt.Fprintf(flag.CommandLine.Output(), "Missing path argument(s)\n")
		os.Exit(1)
	}
	paths := flag.Args()

	logger := zap.New(zap.UseFlagOptions(&logOpts))

	for _, path := range paths {
		st, err := os.Stat(path)
		isNotExist := false

		if err != nil {
			if !os.IsNotExist(err) {
				logger.Error(err, "Error during stat", "path", path)
				os.Exit(1)
			} else {
				isNotExist = true
			}
		}
		if isNotExist || !st.IsDir() {
			logger.V(0).Info("Not a directory", "path", path)
			os.Exit(1)
		}
	}

	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)

	var checker Checker
	switch mode {
	case WatchModeConfigMap:
		checker = ConfigMapChecker
	case WatchModeFile:
		checker = FileChecker
	default:
		panic(fmt.Sprintf("Unknown mode: %v", mode))
	}

	w, err := NewWatcher(logger.WithName("watcher"), checker, paths)
	if err != nil {
		logger.Error(err, "Unable to construct watcher")
		os.Exit(1)
	}
	defer w.Close()

	err = w.Register()
	if err != nil {
		logger.Error(err, "Unable to register watcher")
		os.Exit(1)
	}

	sigHandler, err := NewSignalHandler(logger.WithName("signalhandler"), cancel, os.Interrupt, syscall.SIGTERM)
	if err != nil {
		logger.Error(err, "Unable to construct signal handler")
		os.Exit(1)
	}
	defer sigHandler.Close()

	err = sigHandler.Register()
	if err != nil {
		logger.Error(err, "Failed to register signal handler")
		os.Exit(1)
	}

	r := NewReloader(logger.WithName("reloader"), w.Events, pidFile, defaultSignal)
	defer r.Close()

	g, ctx := errgroup.WithContext(ctx)

	g.Go(func() error {
		err = sigHandler.Run(ctx)
		if err != nil {
			logger.Error(err, "Error in signal handler")
			return err
		}

		return nil
	})

	g.Go(func() error {
		err := w.Run(ctx)
		if err != nil {
			logger.Error(err, "Error in watcher")
		}
		return err
	})

	g.Go(func() error {
		err := r.Run(ctx)
		if err != nil {
			logger.Error(err, "Error in reloader")
		}
		return err
	})

	logger.V(1).Info("Waiting for goroutines")
	<-ctx.Done()
	logger.V(1).Info("Context done")
	cancel()

	err = g.Wait()
	if err != nil {
		logger.Error(err, "Error in errgroup")
	}
}
