#!/usr/bin/env bash

set -eu

# shellcheck source=../zsh/browser.sh
source ~/.config/zsh/browser.sh

# shellcheck source=../zsh/pandoc.sh
source ~/.config/zsh/pandoc.sh

# shellcheck source=../zsh/utils.sh
source ~/.config/zsh/utils.sh

MIME_TYPE=$(get_mimetype $fx)

if [[ $MIME_TYPE =~ ^image ]]; then
    imv $fx
    exit 0

elif [[ $MIME_TYPE =~ ^text || $MIME_TYPE = application/json ]]; then
    if [[ $fx == *.md ]]; then
      open_md_in_browser_as_html "$fx"
      exit 0
    fi

    nvim $fx
    exit 0

elif [[ $MIME_TYPE =~ ^video ]]; then
    celluloid $fx
    exit 0

elif [[ $MIME_TYPE = application/pdf ]]; then
  open_in_browser_new_window $fx
  exit 0

else
    # xdg-open $fx
    exit 0
fi
