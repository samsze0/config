# MacOS

```bash
# If were to install in custom dir. But this can cause issues
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew && export PATH="$HOME/homebrew/bin:$PATH"
```

Install command line developer tools
```bash
sudo xcode-select --install
```

Setup system settings
```bash
osx_init
```

Create symlink to icloud:
```bash
ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/cloud
```

Install brew "packages" from `.Brewfile.lock.json`
```bash
brew_install
```

Karabiner:
```bash
cd ~/.config/karabiner && npx tsx config.ts
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

yabai --start-service
skhd --start-service

# Load scripting edition (on login)
sudo yabai --load-sa
```

Sometimes desktop icons will glitch. To fix:
```bash
killall Finder
```

Change default shell to brew's installation of zsh:
```bash
echo /opt/homebrew/bin/zsh | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/zsh
```

Install custom builds of fzf and yazi:
```bash
# Inside fzf project
FZF_VERSION=0 make install
cp <binary> ~/bin

# Inside yazi project
cargo build --release
cp <binary> ~/bin
```
