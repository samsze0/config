#!/usr/bin/env bash

# https://github.com/junegunn/fzf/blob/master/ADVANCED.md

# Return the command line args containing fzf's keybindings, colors and other config
# The return value should be exported as `FZF_DEFAULT_OPTS`
fzf_default_opts() {
	local is_linux
	is_linux=false
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		is_linux=true
	fi

	local colors
	# If is linux, use 090a0d, else use 000000
	local black
	if $is_linux; then
		black="#090a0d"
	else
		black="#0f1118"
	fi
	# Remove newlines and spaces
	colors=$(
		cat <<EOT | tr -d "\n "
    --color=
      bg+:#23283c,
      preview-bg:$black,
      bg:$black,
      border:#535d6c,
      spinner:#549eff,
      hl:#549eff,
      fg:#687184,
      header:#7E8E91,
      info:#549eff,
      pointer:#549eff,
      marker:#687184,
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
