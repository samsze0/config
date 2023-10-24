#!/usr/bin/env bash

NOTIFICATION_DURATION=${1:-2000}  # Fallback to 2000ms

color=$(hyprpicker) || exit 0

wl-copy $color

dunstify "Screenshot copied to clipboard" -t $NOTIFICATION_DURATION