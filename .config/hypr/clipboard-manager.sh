#!/usr/bin/env bash

NOTIFICATION_DURATION=$1

cliphist list | rofi -dmenu | cliphist decode | wl-copy