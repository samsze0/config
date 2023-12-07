#!/usr/bin/env bash

# Serve syncthing in background
syncthing_serve() {
	(syncthing serve --no-browser >~/.cache/syncthing 2>&1 &) # Run in subshell to subpress '&' log
	echo "Serving syncthing at localhost:8384"
}
