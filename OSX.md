# Personal MacOS Setup Walkthrough

## Prerequisites

### Install Command Line Developer Tools

```bash
sudo xcode-select --install
```

### Install Homebrew (Optional: Custom Directory)

```bash
# Standard installation (recommended)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Alternative: Custom directory installation (may cause issues)
# mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew && export PATH="$HOME/homebrew/bin:$PATH"
```

## System Configuration

### Initialize System Settings

```bash
osx_init
```

### Create iCloud Symlink

```bash
ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/cloud
```

### Install Homebrew Packages

```bash
# In nushell
brew-bundle-install
```

### Configure Karabiner-Elements

```bash
cd ~/.config/karabiner && npx tsx config.ts
```

## Optional: Custom Tool Builds

### fzf (Custom Build)

```bash
# Inside fzf project directory
FZF_VERSION=0 make install
cp <binary> ~/bin
```

### Yazi (Custom Build)

```bash
# Build from source
cargo build --release
cp target/release/yazi ~/bin

# Or install from cargo
cargo install --force yazi-build

# Or install latest from git
cargo install --force --git https://github.com/sxyazi/yazi.git yazi-build
```

Reference: [Yazi Installation Guide](https://yazi-rs.github.io/docs/installation/#crates)

Configure Finder settings:

**Advanced Tab:**
- [x] Show all filename extensions
- [x] Show warning before changing an extension
- [x] Show warning before removing from iCloud Drive
- [x] Show warning before emptying the Trash
- [ ] Remove items from the Trash after 30 days
- When performing a search: Search the Current Folder

**General Tab:**
- [ ] Sync Desktop & Documents folders
- [ ] Open folders in tabs instead of new windows

**Sidebar Tab:**
Show these items in the sidebar:
- [ ] Recents
- [x] AirDrop
- [x] Applications
- [x] Desktop
- [x] Documents
- [x] Downloads
- [x] Movies
- [x] Music
- [x] Pictures
- [x] [your username]
- [x] iCloud Drive
- [x] Shared
- [x] [your username]'s MacBook Pro
- [x] Hard disks
- [x] External disks
