# Dotfiles

## MacOS

**Homebrew**
- Install homebrew under custom location (e.g. `~/homebrew`):
  - `mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew`
- `brew install cmacrae/formulae/spacebar koekeishiya/formulae/yabai koekeishiya/formulae/skhd less tree wget curl fd fzf ansible bat bottom node miniforge git ripgrep gnu-sed zoxide gh croc asciiema rustup starship python`
- `brew install visual-studio-code slack postman brave-browser warp homebrew/cask-versions/firefox-developer-edition karabiner-elements docker spotify raycast --cask`

**Karabiner**
- Goto `karabiner/` and run `node config.js`

**Spacebar**
- Spacebar doesn't have apple silicon built
- Install rosetta beforehand with `softwareupdate --install-rosetta`

**Yabai**
- Disable SIP `csrutil disable` (in recovery mode)
- Enable arm64e (apple silicon) `sudo nvram boot-args=-arm64e_preview_abi` (then reboot)
- Load scripting addition `sudo yabai --load-sa`
- Sometimes the desktop icons will appear on top of the windows. To fix this, run `killall Finder`

**XCode**
- `mkdir -p` and `cd` into `~/Library/Developer/Xcode`
- Create symlink by `ln -s ~/.config/xcode/ UserData`

**Bottom**
- Setup alias to `btm --config ~/.config/btm/config.toml`

**x86-64**
- Install rosetta by `softwareupdate --install-rosetta`
- Clone the terminal app and check option `Open with Rosetta`
- (In rosetta) Install homebrew under custom location (e.g. `~/homebrew-x86`):
  - `mkdir homebrew-x86 && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew-x86`
  - `brew install starship pyenv zoxide`

**Blender**
- Setup symbolic link inside e.g. `~/Library/Application\ Support/Blender/` by `ln -s ~/.config/blender/ 3.5`

**iCloud**
- Setup symbolic link in desktop/home by `ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/cloud`

## Windows

**winget**
- `winget install Mozilla.Firefox.DeveloperEdition`
- `winget install Microsoft.PowerToys`
- `winget install Microsoft.WindowsTerminal`

**Link Shell Extension**
- `winget install HermannSchinagl.LinkShellExtension`

**GlazeWM**
- `winget install lars-berger.GlazeWM`