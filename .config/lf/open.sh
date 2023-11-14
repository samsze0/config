#!/usr/bin/env bash

set -eu

source ~/.config/lf/utils.sh

MIME_TYPE=$(get_mimetype $fx)

if [[ $MIME_TYPE =~ ^image ]]; then
    imv $fx
    exit 0
elif [[ $MIME_TYPE =~ ^text || $MIME_TYPE = application/json ]]; then
    nvim $fx
    exit 0
elif [[ $MIME_TYPE =~ ^video ]]; then
    celluloid $fx
    exit 0
else
    # xdg-open $fx
    exit 1
fi
