# MacOS

**Homebrew**

Install homebrew under custom location (e.g. `~/homebrew`):
 
```bash
mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew && export PATH="$HOME/homebrew/bin:$PATH"
```

Install command line developer tools (& XCode ?):

```bash
sudo xcode-select --install
```

Install homebrew formulae and casks
```bash
brew install gojq  # Required by install script
brew_install_from
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

**iCloud**
- Make sym link with `ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/cloud`
