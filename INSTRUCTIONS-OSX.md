# MacOS

Install homebrew under custom location (e.g. `~/homebrew`):
(Apparently installing brew outside of `/opt/homebrew` can cause issues. Check with brew doctor)
```bash

# If were to install in custom dir
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew && export PATH="$HOME/homebrew/bin:$PATH"
```

MacOS settings:
- Enable tap to click in trackpad settings
- Enable double click to select in accessibility > trackpad options
- Disable "Automatically rearrange Spaces" in desktop & dock settings
- Enable auto hide/show dock
- Set default browser to Firefox in general settings

Install command line developer tools (& XCode ?):

```bash
sudo xcode-select --install
```

On newer versions of OSX key repeat is disabled by default, to enable it, run:
```bash
defaults write -g ApplePressAndHoldEnabled -bool false
```

Install github cli and login:
```bash
brew install gh
gh auth login
```

Install browser:
```bash
brew tap homebrew/cask-versions
brew install --cask firefox-developer-edition
```

Remove all apps from dock:
```bash
defaults write com.apple.dock persistent-apps -array
killall Dock
# Or use dockutil
```

Change keyboard repeat delay:

```bash
defaults write -g InitialKeyRepeat -int 13 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -float 1.7     # normal minimum is 2 (30 ms)
```

Create symlink to icloud:
```bash
ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/cloud
```

**Karabiner**
- Goto `karabiner/` and run `node config.js`

**Spacebar**
- Spacebar doesn't have apple silicon built. Install rosetta beforehand with `softwareupdate --install-rosetta`

**Yabai**
- Disable SIP with `csrutil disable` (in recovery mode)
- Enable ARM64E ABI boot option w/ `sudo nvram boot-args=-arm64e_preview_abi` (then reboot again)
- Load scripting addition `sudo yabai --load-sa`
- Sometimes the desktop icons will appear on top of the windows. To fix this, run `killall Finder`

**x86-64**
- Install rosetta with `softwareupdate --install-rosetta`
- Create a terminal emulator clone with option `Open with Rosetta`
- (In rosetta terminal) Install homebrew under custom location (e.g. `~/homebrew-x86`)

```bash
mkdir homebrew-x86 && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew-x86  # Same command as before
```
