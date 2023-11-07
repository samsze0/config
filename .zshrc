# https://apple.stackexchange.com/questions/388622/zsh-zprofile-zshrc-zlogin-what-goes-where
# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout

# Warp still hasn't supported zsh completions yet (i.e. compdef, compctl, compsys, etc.)
# https://github.com/warpdotdev/Warp/issues/2179

# zsh-autocomplete
# https://github.com/marlonrichert/zsh-autocomplete
# source ~/.config/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# fzf-tab
# https://github.com/Aloxaf/fzf-tab/wiki/Configuration
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
# preview directory's content with exa when completing cd or ls
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-min-height 1000

# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# forgit
# https://github.com/wfxr/forgit
source ~/.config/zsh/plugins/forgit/forgit.plugin.zsh
export PATH="$PATH:$HOME/.config/zsh/plugins/forgit/bin"

# Enable zsh completion
autoload -U compinit; compinit
compaudit || (compaudit | xargs chmod go-w)  # Remove group & other write permission for all insecure directories if there are any

check_command_exists() {
    if command -v $1 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

if [ $(arch) = "i386" ]  # OSX rosetta
then
    eval "$($HOME/homebrew-x86/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv-x86"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pip completion --zsh)"

elif [ $(arch) = "x86_64" ]  # Linux / NixOS
then
    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    if check_command_exists pyenv; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi
    check_command_exists pip && eval "$(pip completion --zsh)"

    export PATH="/usr/local/cuda/bin:$PATH"

    # ZLE bindings
    bindkey "^[[H" beginning-of-line
    bindkey "^[[F" end-of-line
    bindkey "^H" backward-kill-word

    if [[ $(uname -a) =~ "nixos" ]]  # NixOS
    then
        alias screen-record="bash ~/.config/hypr/screen-record.sh"
        alias nixos-reload="bash ~/.config/hypr/nixos-reload.sh"

        alias code='code --disable-gpu'
    fi
   
else  # OSX m1
    eval "$(/opt/homebrew/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pip completion --zsh)"
fi

export PATH=$HOME/bin:${PATH}

alias ssha='eval $(ssh-agent) && ssh-add'
alias gg='git-forgit'

# FZF
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md
FZF_COLORS=$(cat << EOT | tr -d "\n "  # Remove newlines and spaces
    --color=
    bg+:#333333,
    preview-bg:#111111,
    bg:#000000,
    border:#555555,
    spinner:#4C9BFF,
    hl:#777777,
    fg:#777777,
    header:#7E8E91,
    info:#4C9BFF,
    pointer:#4C9BFF,
    marker:#FE946E,
    fg+:#CBD1DA,
    prompt:#FE946E,
    hl+:#FE946E
EOT
)

export FZF_DEFAULT_OPTS="$FZF_COLORS --layout=reverse --info=inline --border --margin=1 --padding=1"
