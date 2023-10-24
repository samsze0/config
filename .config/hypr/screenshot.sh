#!/usr/bin/env bash

IMAGE_FORMAT=${1:-png}  # Fallback to png
NOTIFICATION_DURATION=${2:-2000}  # Fallback to 2000ms

geometry=$(slurp) || exit 0

grim -t $IMAGE_FORMAT -g "$geometry" - |
    # convert - -shave 1x1 $IMAGE_FORMAT:- | # Shave 1px border (with ImageMagick)
    wl-copy

dunstify "Screenshot copied to clipboard" -t $NOTIFICATION_DURATION