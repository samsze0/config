#!/usr/bin/env bash

NOTIFICATION_DURATION=$1

geometry=$(slurp)

if [ $? -eq 1 ]; then
    exit 0
fi

grim -g "$geometry" - | wl-copy

dunstify "Screenshot copied to clipboard" -t $NOTIFICATION_DURATION