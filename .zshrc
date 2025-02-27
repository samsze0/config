# Custom lib
. ~/.config/zsh/tailscale.sh
. ~/.config/zsh/utils.sh
. ~/.config/zsh/pandoc.sh
. ~/.config/zsh/image.sh
. ~/.config/zsh/browser.sh
. ~/.config/zsh/kitty.sh
. ~/.config/zsh/nix.sh
. ~/.config/zsh/fzf.sh
. ~/.config/zsh/socket.sh
. ~/.config/zsh/unix.sh
. ~/.config/zsh/git.sh
. ~/.config/zsh/homebrew.sh
. ~/.config/zsh/syncthing.sh
. ~/.config/zsh/osx.sh
. ~/.config/zsh/bat.sh
. ~/.config/zsh/lemminx.sh
. ~/.config/zsh/azure.sh
. ~/.config/zsh/openssh.sh
. ~/.config/zsh/android.sh
. ~/.config/zsh/other-deps.sh
. ~/.config/zsh/network.sh
. ~/.config/zsh/redis.sh
. ~/.config/zsh/nvim.sh
. ~/.config/zsh/yazi.sh

# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
. ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
. ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=blue,bold'

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
		export NVM_DIR="$HOME/.nvm"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
		[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
	else                                                                # OSX
		export NVM_DIR="$HOME/.nvm"
		if [[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
			. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
		fi
		if [[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]]; then
			. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
		fi
	fi
}

function init_azure_cli() {
  # Requires system package python-argcomplete
  if check_command_exists az && check_command_exists register-python-argcomplete; then
    if [[ -s "$HOMEBREW_PREFIX/etc/bash_completion.d/az" ]]; then
      . "$HOMEBREW_PREFIX/etc/bash_completion.d/az"
      eval "$(register-python-argcomplete az)"
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

# zsh completion (& bash completion) (need to be after brew shellenv)
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
autoload -U compinit
compinit
autoload -U bashcompinit
bashcompinit
compaudit || (compaudit | xargs chmod go-w) # Remove group & other write permission for all insecure directories if there are any

init_starship
init_zoxide
init_pyenv
init_pip
init_rbenv
init_nvm
init_azure_cli

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
alias f='yazi'
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
export XDG_CONFIG_HOME="$HOME/.config"

# man locale
# locale -a to list all available locales
# export LANG="en_US.UTF-8"
# export LC_ALL="$LANG"
