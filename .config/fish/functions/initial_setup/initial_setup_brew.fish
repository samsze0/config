function initial_setup_brew 
  # Formulaes
  set -l plugins \
    bat \
    bash-language-server \
    bottom \
    curl \
    cmacrae/formulae/spacebar \
    fd \
    fzf \
    efm-langserver \
    git \
    go \
    golangci-lint \
    gnu-sed \
    imagemagick \
    java \
    koekeishiya/formulae/yabai \
    koekeishiya/formulae/skhd \
    lua-language-server \
    lua \
    less \
    llvm \
    mkcert \
    ninja \
    node \
    python@3.9 \
    python@3.10 \
    pyright \
    prettier \
    pandoc \
    pnpm \
    tree \
    texlab \
    tmux \
    terraform \
    terraform-ls \
    rust \
    ripgrep \
    rust-analyzer \
    rust \
    ocaml \
    sphinx-doc \
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
    visual-studio-code

  for cask in $casks
    brew install --cask $cask
  end

  # Brew background services
  brew services start yabai > /dev/null
  brew services start skhd > /dev/null
  brew services start spacebar > /dev/null

  # Xmake color
  xmake g --theme=plain > /dev/null
end
