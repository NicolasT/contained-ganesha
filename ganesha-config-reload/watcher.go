package main

import (
	"context"
	"path/filepath"

	"github.com/go-logr/logr"

	"github.com/fsnotify/fsnotify"
)

type Checker = func(fsnotify.Event) (bool, error)

type watcher struct {
	log    logr.Logger
	w      *fsnotify.Watcher
	paths  []string
	Events chan interface{}
	check  func(fsnotify.Event) (bool, error)
}

func NewWatcher(log logr.Logger, check Checker, paths []string) (*watcher, error) {
	w, err := fsnotify.NewWatcher()
	if err != nil {
		log.Error(err, "Unable to create watcher")
		return nil, err
	}

	return &watcher{
		log:    log,
		w:      w,
		paths:  paths,
		Events: make(chan interface{}),
		check:  check,
	}, nil
}

func (w *watcher) Register() error {
	for _, path := range w.paths {
		log := w.log.WithValues("path", path)

		log.Info("Adding watch on path")
		err := w.w.Add(path)
		if err != nil {
			w.log.Error(err, "Unable to add path to watchlist")
			return err
		}
	}

	return nil
}

func (w *watcher) Run(ctx context.Context) error {
	for {
		w.log.V(1).Info("Waiting for events")

		select {
		case evt := <-w.w.Events:
			log := w.log.WithValues("path", evt.Name, "op", evt.Op)
			log.V(1).Info("Received event")
			isEvent, err := w.check(evt)
			if err != nil {
				log.Error(err, "Failed to check event")
			} else {
				if isEvent {
					log.Info("Detected config update")
					w.Events <- nil
				}
			}
		case err := <-w.w.Errors:
			w.log.Error(err, "Watcher error")
		case <-ctx.Done():
			w.log.V(1).Info("Context done")
			return nil
		}
	}
}

func (w *watcher) Close() {
	w.log.V(1).Info("Closing events channel")
	close(w.Events)

	w.log.V(1).Info("Closing watcher")
	err := w.w.Close()
	if err != nil {
		w.log.Error(err, "Error while closing fswatcher")
	}
}

func ConfigMapChecker(evt fsnotify.Event) (bool, error) {
	return (filepath.Base(evt.Name) == "..data") && (evt.Op&fsnotify.Create != 0), nil
}

func FileChecker(evt fsnotify.Event) (bool, error) {
	return true, nil
}
