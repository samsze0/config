#!/usr/bin/env bash

# https://github.com/junegunn/fzf/blob/master/ADVANCED.md

# Return the command line args containing fzf's keybindings, colors and other config
# The return value should be exported as `FZF_DEFAULT_OPTS`
fzf_init() {
  KEYMAPS=" \
    --bind 'alt-a:toggle-all' \
    --bind 'alt-i:toggle' \
  "

  COLORS=$(cat << EOT | tr -d "\n "  # Remove newlines and spaces
    --color=
      bg+:#2c313c,
      preview-bg:#131516,
      bg:#000000,
      border:#535d6c,
      spinner:#549eff,
      hl:#549eff,
      fg:#687184,
      header:#7E8E91,
      info:#549eff,
      pointer:#549eff,
      marker:#cbd1da,
      fg+:#cbd1da,
      prompt:#cbd1da,
      hl+:#cbd1da
EOT
  )
  echo "$COLORS $KEYMAPS \
    --layout=reverse \
    --info=inline \
    --border \
    --margin=1 \
    --padding=1 \
    --pointer='' \
    --marker='' \
  "
}
