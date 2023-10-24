#!/usr/bin/env bash

NOTIFICATION_DURATION=${1:-2000}  # Fallback to 2000ms

wl-paste | swappy -f -