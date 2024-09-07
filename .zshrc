# Custom lib
source ~/.config/zsh/tailscale.sh
source ~/.config/zsh/utils.sh
source ~/.config/zsh/pandoc.sh
source ~/.config/zsh/image.sh
source ~/.config/zsh/browser.sh
source ~/.config/zsh/kitty.sh
source ~/.config/zsh/nix.sh
source ~/.config/zsh/fzf.sh
source ~/.config/zsh/socket.sh
source ~/.config/zsh/unix.sh
source ~/.config/zsh/git.sh
source ~/.config/zsh/homebrew.sh
source ~/.config/zsh/syncthing.sh
source ~/.config/zsh/osx.sh
source ~/.config/zsh/bat.sh
source ~/.config/zsh/lemminx.sh
source ~/.config/zsh/azure.sh
source ~/.config/zsh/openssh.sh
source ~/.config/zsh/android.sh
source ~/.config/zsh/other-deps.sh
source ~/.config/zsh/network.sh
source ~/.config/zsh/redis.sh
source ~/.config/zsh/nvim.sh
source ~/.config/zsh/yazi.sh

# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'

# zsh completion
autoload -U compinit
compinit
compaudit || (compaudit | xargs chmod go-w) # Remove group & other write permission for all insecure directories if there are any

function init_pyenv() {
	if check_command_exists pyenv; then
		export PYENV_ROOT="$HOME/.pyenv"
		mkdir -p "$PYENV_ROOT"
		export PATH="$PYENV_ROOT/bin:$PATH"
		eval "$(pyenv init -)"
	fi
}

function init_pip() {
	if check_command_exists pip; then
		eval "$(pip completion --zsh)"
	fi
}

function init_starship() {
	if check_command_exists starship; then
		eval "$(starship init zsh)"
	fi
}

function init_zoxide() {
	if check_command_exists zoxide; then
		eval "$(zoxide init zsh)"
	fi
}

function init_rbenv() {
	if check_command_exists rbenv; then
		eval "$(rbenv init - zsh)"
	fi
}

function init_nvm() {
	if [ $(arch) = "x86_64" ]; then # Linux / NixOS
	else                            # OSX
		export NVM_DIR="$HOME/.nvm"
		if [[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
			. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
		fi
		if [[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]]; then
			. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
		fi
	fi
}

if [ $(arch) = "x86_64" ]; then # Linux / NixOS
	export PATH="/usr/local/cuda/bin:$PATH"

	if [[ $(uname -a) =~ "nixos" ]]; then # NixOS
		alias nix-gc='nix-collect-garbage -d'
		alias nix-dev='nix develop -c zsh'
		function nix-run() {
			nix run nixpkgs#"$1"
		}

		if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then # Hyprland
			alias nixos-r='sudo nixos-rebuild switch --flake ~/nixos-config#hyprland --install-bootloader'
			alias screen-record="bash ~/.config/hypr/screen-record.sh"

			export NOTIFIER=""

		else # GNOME
			alias nixos-r='sudo nixos-rebuild switch --flake ~/nixos-config#gnome --install-bootloader'
			alias code='code --disable-gpu'
		fi

		export BROWSER="firefox"
		export IMAGE_VIEWER="imv"
		export VIDEO_PLAYER="celluloid"
	fi
else # OSX
	HOMEBREW_PREFIX="/opt/homebrew"
	HOMEBREW_X86_PREFIX="/opt/homebrew-x86"

	if [ $(arch) = "i386" ]; then # Rosetta
		eval "$($HOMEBREW_X86_PREFIX/bin/brew shellenv)"
	else # M1
		eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

		export PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"
		export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk"
		export JDTLS_HOME="$HOMEBREW_PREFIX/opt/jdtls/libexec"

		export PATH="$HOMEBREW_PREFIX/opt/postgresql@16/bin:$PATH"

		export PATH="$HOMEBREW_PREFIX/opt/mysql@8.0/bin:$PATH"
	fi

	export BROWSER="open -a '/Applications/Firefox Developer Edition.app'"
	export IMAGE_VIEWER="open"
	export VIDEO_PLAYER="iina"
	export NOTIFIER="osx_notify"

	export ANDROID_HOME="$HOME/Library/Android/sdk"
	export PATH="$ANDROID_HOME/emulator:$PATH"
	export PATH="$ANDROID_HOME/tools:$PATH"
fi

init_starship
init_zoxide
init_pyenv
init_pip
init_rbenv
init_nvm

mkdir -p "$HOME/bin"
export PATH=$HOME/bin:${PATH}
export PATH=/usr/local/bin:${PATH}

# zle (line editor)
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^H" backward-kill-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

alias ssha='eval $(ssh-agent) && ssh-add'
alias fzf-man='man $(echo $(man -k . | fzf) | cut -d " " -f 1)'
alias duf='duf -theme ansi'
alias ll='eza -l'
alias delta-diff='delta --raw'
alias ts-get='tailscale_get'
alias ts-send='tailscale_send'
alias jq='gojq'
alias v='nvim'
alias lf='PAGER="nvim -RM" lf'
alias y='yazi'
alias c='code'

# https://github.com/kovidgoyal/kitty/discussions/3873
alias sshs='TERM=xterm-256color sshs'

export FZF_DEFAULT_OPTS=$(fzf_default_opts)

# zsh history
setopt share_history
export HISTFILE=~/.zhistory
export SAVEHIST=100 # Capacity of no. lines
export HISTSIZE=50  # Capacity of no. lines for a session

export SHELL="$(which zsh)"
export PAGER="less"
export EDITOR="nvim"
export MANPAGER="nvim +Man\!" # https://neovim.io/doc/user/filetype.html#ft-man-plugin

# Prevent "repeating characters" issue when inside a ssh session that also uses zsh
# man locale
# locale -a to list all available locales
# export LANG="en_US.UTF-8"
# export LC_ALL="$LANG"
