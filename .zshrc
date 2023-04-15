# https://apple.stackexchange.com/questions/388622/zsh-zprofile-zshrc-zlogin-what-goes-where
# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout

if [ $(arch) = "i386" ]  # rosetta / x86
then
    eval "$($HOME/homebrew/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv-x86"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
else
    eval "$(/opt/homebrew/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"
    export PATH="$HOMEBREW_PREFIX/opt/curl/bin:$PATH"
    export PATH="$HOMEBREW_PREFIX/opt/llvm/bin:$PATH"
    export PATH="$HOMEBREW_CELLAR/qt@5/5.15.8_2/bin:$PATH"

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

export PATH=$HOME/bin:${PATH}
