#!/usr/bin/env bash

NOTIFICATION_DURATION=${1:-2000}  # Fallback to 2000ms

cliphist list | rofi -dmenu | cliphist decode | wl-copy