function initial_setup_brew 
  # Formulaes
  set -l plugins \
    bat \
    bottom \
    curl \
    cmacrae/formulae/spacebar \
    fd \
    fzf \
    git \
    go \
    gnu-sed \
    imagemagick \
    koekeishiya/formulae/yabai \
    koekeishiya/formulae/skhd \
    lua-language-server \
    lua \
    less \
    llvm \
    node \
    python@3.9 \
    python@3.10 \
    pyright \
    pandoc \
    pnpm \
    tree \
    texlab \
    tmux \
    rust \
    ripgrep \
    rust-analyzer \
    rust \
    wget

  for plugin in $plugins
    brew install $plugin
  end

  # Casks
  set -l casks \
    adobe-acrobat-reader \
    background-music \
    brave-browser \
    blender \
    discord \
    docker \
    google-cloud-sdk \
    karabiner-elements \
    kitty \
    keycastr \
    obs \
    unity \
    spotify \
    linearmouse \
    warp \
    visual-studio-code

  for cask in $casks
    brew install --cask $cask
  end

  # Brew background services
  brew services start yabai > /dev/null
  brew services start skhd > /dev/null
  brew services start spacebar > /dev/null
end
