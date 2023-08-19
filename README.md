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
- For how to bypass TPM (Windows 11 installation), see [here](https://www.tomshardware.com/how-to/bypass-windows-11-tpm-requirement)
- Avoid linking with Microsoft. Create a new user that doesn't link to Microsoft and give him admin privileges
- Install Nvidia Graphics Driver
- Install the [media feature pack](https://support.microsoft.com/en-us/windows/media-feature-pack-for-windows-n-8622b390-4ce6-43c9-9b42-549e5328e407) if you are on the windows "N" version. Also install the OpenSSH server feature
- Install drivers from [your motherboard support page](https://www.msi.com/Motherboard/{}/support)

**MSVC**
- Visual Studio comes with the microsoft C/C++ compiler/build tools. Currently this is the only method of obtaining those build tools

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
- Development stuff: `scoop install versions/firefox-developer extras/powertoys main/nvm extras/vscode main/rustup main/starship main/croc main/gh main/ripgrep main/curl main/wget main/less main/fd main/fzf main/bat main/zoxide main/gotop main/ln extras/whkd  extras/vcredist2022 sudo which nerd-fonts/Hack-NF cmake`
- For Windows 10: `scoop install extras/windows-terminal`

**winget**
- Require microsoft store login if the source is from tore``
- `winget install Microsoft.PowerShell` (for Powershell >=7; optional)
- `winget install fancywm`

**Symlinks**
- E.g. `sudo ln -s C:\Users\{user}\.config\windows-terminal\settings.json settings.json`. Note that absolute path must be used
- Alternatively, run the `setup` powershell script, which setup all the necessary symlinks

**pyenv-win**
- There is an [ongoing issue](https://github.com/pyenv-win/pyenv-win/issues/449) with scoop's install of `pyenv-win`. It will fail to install the python runtime and will get the `error installing "core" component MSI.` error message. For now ~~run custom command for installing (or just use the `pyenv-install-python` function defined inside `profile.ps1`)~~ just don't install `pyenv-win` via scoop
- Install `pyenv-win` via `Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"`. This will install `pyenv-win` inside `~/.pyenv/`
- Install e.g. `pyenv install 3.10.11` and set it as the global/default via `pyenv global 3.10.11`

## NixOS

- Load the [flake (TODO)]() and run `sudo nixos-rebuild switch`

**GNOME**
- Use `dconf` to load the keybindings config i.e. `dconf load /org/gnome/<schema> < config_file`. Possible schemas include:
  - `desktop/wm/keybindings/`
  - `settings-daemon/plugins/media-keys/`
  - `shell/keybindings/`
- Use `dconf dump` to dump existing settings to this repo

**Cinnamon**
- Use `dconf` to load and dump the desktop environment config
- `dconf load /org/cinnamon/ < ~/.config/cinnamon.ini`
- `dconf dump /org/cinnamon/ > ~/.config/cinnamon.ini`
