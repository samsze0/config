#!/usr/bin/env bash

# https://github.com/junegunn/fzf/blob/master/ADVANCED.md

# Return the command line args containing fzf's keybindings, colors and other config
# The return value should be exported as `FZF_DEFAULT_OPTS`
fzf_init() {
	local colors
	# Remove newlines and spaces
	colors=$(
		cat <<EOT | tr -d "\n "
    --color=
      bg+:#23283c,
      preview-bg:#000000,
      bg:#000000,
      border:#535d6c,
      spinner:#549eff,
      hl:#549eff,
      fg:#687184,
      header:#7E8E91,
      info:#549eff,
      pointer:#549eff,
      marker:#cbd1da,
      fg+:#95a1b3,
      prompt:#549eff,
      hl+:#549eff
EOT
	)

	# Remove new lines and squeeze space
	cat <<EOT | tr -d "\n" | tr -s " "
  $colors
  
  --layout=reverse
  --info=inline
  --border
  --margin=1
  --padding=1
  --pointer=''
  --marker=''
  
  --bind 'ctrl-a:toggle-all'
  --bind 'ctrl-i:toggle'
EOT
}

fzf_git_grep() {
	git grep --line-number '' |
		fzf --delimiter : \
			--preview 'bat --style=full --color=always --highlight-line {2} {1}' \
			--preview-window '~3,+{2}+3/2'
}
