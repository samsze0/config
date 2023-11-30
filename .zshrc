# Custom lib
source ~/.config/zsh/tailscale.sh
source ~/.config/zsh/utils.sh
source ~/.config/zsh/pandoc.sh
source ~/.config/zsh/image.sh
source ~/.config/zsh/browser.sh
source ~/.config/zsh/kitty.sh
source ~/.config/zsh/nix.sh
source ~/.config/zsh/gitconfig.sh
source ~/.config/zsh/fzf.sh
source ~/.config/zsh/socket.sh
source ~/.config/zsh/unix.sh
source ~/.config/zsh/git.sh

# fzf-tab
# https://github.com/Aloxaf/fzf-tab/wiki/Configuration
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
# preview directory's content with exa when completing cd or ls
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-min-height 1000

# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable zsh completion
autoload -U compinit
compinit
compaudit || (compaudit | xargs chmod go-w) # Remove group & other write permission for all insecure directories if there are any

function pyenv_init_if_available() {
	if check_command_exists pyenv; then
		export PYENV_ROOT="$HOME/.pyenv"
		export PATH="$PYENV_ROOT/bin:$PATH"
		eval "$(pyenv init -)"
	fi
}

function pip_init_if_available() {
	if check_command_exists pip; then
		eval "$(pip completion --zsh)"
	fi
}

function starship_init_if_available() {
	if check_command_exists starship; then
		eval "$(starship init zsh)"
	fi
}

function zoxide_init_if_available() {
	if check_command_exists zoxide; then
		eval "$(zoxide init zsh)"
	fi
}

if [ $(arch) = "x86_64" ]; then # Linux / NixOS
	starship_init_if_available
	zoxide_init_if_available
	pyenv_init_if_available
	pip_init_if_available

	export PATH="/usr/local/cuda/bin:$PATH"

	# ZLE bindings
	bindkey "^[[H" beginning-of-line
	bindkey "^[[F" end-of-line
	bindkey "^H" backward-kill-word

	if [[ $(uname -a) =~ "nixos" ]]; then # NixOS
		alias nix-gc='nix-collect-garbage -d'
		alias nix-dev='nix develop -c zsh'
		function nix-run() {
			nix run nixpkgs#"$1"
		}

		if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then # Hyprland
			alias nixos-r='sudo nixos-rebuild switch --flake ~/nixos-config#hyprland --install-bootloader'
			alias screen-record="bash ~/.config/hypr/screen-record.sh"
		else # GNOME
			alias nixos-r='sudo nixos-rebuild switch --flake ~/nixos-config#gnome --install-bootloader'
			alias code='code --disable-gpu'
		fi
	fi

elif [ $(arch) = "i386" ]; then # OSX rosetta
	eval "$($HOME/homebrew-x86/bin/brew shellenv)"

	starship_init_if_available
	zoxide_init_if_available
	pyenv_init_if_available
	pip_init_if_available

else # OSX m1
	eval "$($HOME/homebrew/bin/brew shellenv)"

	starship_init_if_available
	zoxide_init_if_available
	pyenv_init_if_available
	pip_init_if_available
fi

export PATH=$HOME/bin:${PATH}

alias ssha='eval $(ssh-agent) && ssh-add'
alias man-fzf='man $(echo $(man -k . | fzf) | cut -d " " -f 1)'
alias duf='duf -theme ansi'
alias ll='eza -l'
alias diff-delta='delta --raw'
alias ts-get='tailscale_get'
alias ts-send='tailscale_send'
alias jq='gojq'
alias v='nvim'
alias vv='neovide'
alias lf='PAGER="nvim -RM" lf'

export FZF_DEFAULT_OPTS=$(fzf_init)

# ZSH history
setopt share_history
export HISTFILE=~/.zhistory
export SAVEHIST=100 # Capacity of no. lines
export HISTSIZE=50  # Capacity of no. lines for a session

# Default apps
export SHELL="$(which zsh)"
export PAGER="less"
export EDITOR="nvim"
export BROWSER="firefox"
export MANPAGER="nvim +Man\!" # https://neovim.io/doc/user/filetype.html#ft-man-plugin
