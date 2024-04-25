# MacOS

```bash
# If were to install in custom dir. But this can cause issues
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew && export PATH="$HOME/homebrew/bin:$PATH"
```

MacOS settings:
- Drag lock in `accessibility > pointer control > trackpad options`
- Disable `Automatically rearrange Spaces`

Install command line developer tools
```bash
sudo xcode-select --install
```

On newer versions of OSX key repeat is disabled by default, to enable it, run:
```bash
defaults write -g ApplePressAndHoldEnabled -bool false
```

Remove all app icons from dock:
```bash
defaults write com.apple.dock persistent-apps -array
killall Dock
# Or use dockutil
```

Change keyboard repeat delay:
```bash
defaults write -g InitialKeyRepeat -int 13 # by default minimum is 15 (225 ms)
defaults write -g KeyRepeat -float 1.7     # by default minimum is 2 (30 ms)
```

Create symlink to icloud:
```bash
ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/cloud
```

Karabiner:
```bash
cd ~/.config/karabiner && node config.js
```

Spacebar:
```bash
# Spacebar doesn't have apple silicon built. Need to install rosetta
softwareupdate --install-rosetta
```

Yabai:
```bash
# Disable SIP (in recovery mode)
csrutil disable

# Enable ARM64E ABI boot option (need reboot)
sudo nvram boot-args=-arm64e_preview_abi

# Load scripting edition
sudo yabai --load-sa
```

Sometimes desktop icons will glitch. To fix:
```bash
killall Finder
```

App store:
- ColorSlurp
- Outline
- Klack
