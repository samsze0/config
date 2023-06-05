# Dotfiles

- `git clone` this repo (SSH) into a temporary folder
- Move all content from the temp folder into `~`

## MacOS

**Homebrew**
- Install homebrew under custom location (e.g. `~/homebrew`):
  - `mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew`
- Formulae: `brew install cmacrae/formulae/spacebar koekeishiya/formulae/yabai koekeishiya/formulae/skhd less tree wget curl fd fzf bat bottom nvm git ripgrep gnu-sed zoxide gh croc rustup starship pyenv`
- Cask: `brew install visual-studio-code brave-browser warp homebrew/cask-versions/firefox-developer-edition karabiner-elements docker raycast --cask`

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

- Download Nvidia Graphics Driver

**Scoop**
- Scoop is installed in `~/scoop/` by default. Doesn't interfere with other users' programs
- Scoop doesn't pollute PATH (similar to Homebrew)
- Each installed program is isolated and independent (no dependencies? Scoop isn't a package manager)
- Install scoop: `iwr -useb get.scoop.sh | iex`
- Install git: `scoop install main/git`
- Add "buckets":
  - `scoop bucket add extras`
  - `scoop bucket add versions`
  - `scoop bucket add nerd-fonts`
- Development stuff: `scoop install versions/firefox-developer extras/powertoys  extras/glazewm main/nvm main/pyenv extras/vscode main/rustup main/starship main/croc main/gh main/ripgrep main/curl main/wget main/less main/fd main/fzf main/bat main/zoxide main/gotop main/ln extras/whkd extras/komorebi extras/vcredist2022 sudo`
- For Windows 10: `scoop install extras/windows-terminal nerd-fonts/Hack-NF`

**Powershell >=7** (Optinal)
- `winget install Microsoft.PowerShell`

**Symlinks**
- E.g. `sudo ln -s C:\Users\{user}\.config\windows-terminal\settings.json settings.json`. Note that absolute path must be used