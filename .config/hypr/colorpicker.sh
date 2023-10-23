#!/usr/bin/env bash

NOTIFICATION_DURATION=$1

color=$(hyprpicker)

if [ ${#color} -eq 0 ]; then
    exit 0
fi

wl-copy $color

dunstify "Screenshot copied to clipboard" -t $NOTIFICATION_DURATION