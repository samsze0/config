# https://apple.stackexchange.com/questions/388622/zsh-zprofile-zshrc-zlogin-what-goes-where
# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout

if [ $(arch) = "i386" ]  # rosetta / x86
then
    eval "$($HOME/homebrew-x86/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv-x86"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
else
    eval "$(/opt/homebrew/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

export PATH=$HOME/bin:${PATH}

alias ssha='eval $(ssh-agent) && ssh-add'
alias ll='ls -l'