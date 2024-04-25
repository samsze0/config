#!/usr/bin/env bash

NOTIFICATION_DURATION=${1:-2000}  # Fallback to 2000ms

TEMP_FILENAME=~/Desktop/screenshot-edit.png

wl-paste | swappy -f - -o $TEMP_FILENAME
