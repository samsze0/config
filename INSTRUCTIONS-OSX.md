# MacOS

**Homebrew**

Install homebrew under custom location (e.g. `~/homebrew`):
 
```bash
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew
```

Formulae
```bash
brew install \
  cmacrae/formulae/spacebar \
  koekeishiya/formulae/yabai \
  koekeishiya/formulae/skhd \
  less \
  tree \
  wget \
  curl \
  fd \
  fzf \
  bat \
  bottom \
  nvm \
  git \
  ripgrep \
  gnu-sed \
  zoxide \
  gh \
  croc \
  rustup \
  starship \
  pyenv \
```

Cask
```bash
brew install --cask \
  visual-studio-code \
  brave-browser \
  warp \
  homebrew/cask-versions/firefox-developer-edition \
  karabiner-elements \
  docker \
  raycast 
```

**Karabiner**
- Goto `karabiner/` and run `node config.js`

**Spacebar**
- Spacebar doesn't have apple silicon built. Install rosetta beforehand with `softwareupdate --install-rosetta`

**Yabai**
- Disable SIP with `csrutil disable` (in recovery mode)
- Enable arm64e (apple silicon) `sudo nvram boot-args=-arm64e_preview_abi` (then reboot)
- Load scripting addition `sudo yabai --load-sa`
- Sometimes the desktop icons will appear on top of the windows. To fix this, run `killall Finder`

**x86-64**
- Install rosetta with `softwareupdate --install-rosetta`
- Create a terminal emulator clone with option `Open with Rosetta`
- (In rosetta terminal) Install homebrew under custom location (e.g. `~/homebrew-x86`)

```bash
mkdir homebrew-x86 && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew-x86
```

**iCloud**
- Make sym link with `ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/cloud`
