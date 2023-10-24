#!/usr/bin/env bash

FILENAME=$1

geometry=$(slurp) || exit 0

wf-recorder -g "$geometry" -f "$FILENAME" 2>/dev/null || exit 0

mpv "$FILENAME" > /dev/null 2>&1