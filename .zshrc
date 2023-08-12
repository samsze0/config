# https://apple.stackexchange.com/questions/388622/zsh-zprofile-zshrc-zlogin-what-goes-where
# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout

# Note: Warp still hasn't supported zsh completions yet (i.e. compdef, compctl, compsys, etc.)
# https://github.com/warpdotdev/Warp/issues/2179

if [ $(arch) = "i386" ]  # OSX rosetta / x86
then
    eval "$($HOME/homebrew-x86/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv-x86"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pip completion --zsh)"

elif [ $(arch) = "x86_64" ]  # Linux
then
    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pip completion --zsh)"

    export PATH="/usr/local/cuda/bin:$PATH"
    
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
alias btmm='btm --config ~/.config/btm/config.toml'