#!/usr/bin/env bash

osx_init() {
	defaults write -g InitialKeyRepeat -int 13 # normal minimum is 15 (225 ms)
	defaults write -g KeyRepeat -float 1.7     # normal minimum is 2 (30 ms)

	ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/cloud
}

# Show notification using AppleScript
osx_notify() {
  osascript -e "display notification \"$2\" with title \"$1\""
}
