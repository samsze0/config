#!/usr/bin/env bash

# Show notification using AppleScript
osx_notify() {
	osascript -e "display notification \"$2\" with title \"$1\""
}
