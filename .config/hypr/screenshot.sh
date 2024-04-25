#!/usr/bin/env bash

IMAGE_FORMAT=${1:-png}  # Fallback to png
NOTIFICATION_DURATION=${2:-2000}  # Fallback to 2000ms

geometry=$(slurp) || exit 0

TEMP_FILE=~/Desktop/screenshot.png
touch $TEMP_FILE

grim -t $IMAGE_FORMAT -g "$geometry" - |
    convert - -shave 1x1 $IMAGE_FORMAT:- > $TEMP_FILE  # Shave 1px border (with ImageMagick)

wl-copy < $TEMP_FILE

dunstify "Screenshot copied to clipboard" -t $NOTIFICATION_DURATION
