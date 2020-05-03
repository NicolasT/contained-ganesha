package main

import "flag"

type watchMode string

const (
	WatchModeConfigMap watchMode = "configmap"
	WatchModeFile      watchMode = "file"
)

func (w *watchMode) String() string {
	return string(*w)
}

func (w *watchMode) Set(s string) error {
	switch s {
	case string(WatchModeConfigMap):
		*w = WatchModeConfigMap
		return nil
	case string(WatchModeFile):
		*w = WatchModeFile
		return nil
	default:
		return flag.ErrHelp
	}
}
