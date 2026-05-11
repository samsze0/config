# Personal Dotfiles

Personal dotfiles and system configuration. This repo is macOS-first, with best-effort Linux support for shared shell, terminal, editor, and tool configs.

The repository uses an inverted `.gitignore`: everything is ignored by default, then specific configs are allowlisted. Use `git ls-files` to see what is actually version controlled.

## Quick Setup

Clone the repo and copy the tracked configuration into `$HOME`:

```shell
git clone https://github.com/samsze0/config --recursive config
cp -R config/{.,}* ~
```

Private submodules, such as Homebrew bundle profiles, require access to their
Gitea repositories:

```shell
git submodule update --init --recursive
```

Review the worktree after copying, especially if the machine already has local dotfiles:

```shell
git status --short
git ls-files
```

## What's Included

- **Shell:** Nushell, Zsh entrypoint, and Zsh plugin submodules
- **Terminals:** Kitty, Ghostty, tmux
- **Editors:** Zed settings, keymap, and tasks
- **Window management:** AeroSpace
- **CLI tools:** Yazi, Starship, bat, bottom, Topiary, tmuxinator
- **Keyboard:** Karabiner-Elements generated config source
- **Audio:** PulseAudio macOS override
- **Packages:** Homebrew bundle profiles in a private submodule

## macOS

macOS is the primary target for this repo. See [OSX.md](./OSX.md) for the setup walkthrough.

Common setup commands:

```shell
# Install packages from an interactive Homebrew bundle selector
brew-bundle-install

# Generate Karabiner configuration
cd ~/.config/karabiner && bun run generate

# Generate Starship configuration
cd ~/.config/starship && bun run generate
```

The shell configs handle Apple Silicon and Rosetta/Homebrew prefix differences.

## Linux

Linux support is best effort for shared tracked configs. Current tracked Linux-aware pieces include:

- Nushell environment setup for Linux
- Starship prompt metadata for Linux
- A tmuxinator profile for a Linux workstation

## Maintenance

Before editing, check what is tracked:

```shell
git ls-files
git status --short
```

Avoid adding machine-local state, app histories, caches, secrets, or generated private config. If a config should become part of the repo, add it intentionally and update the allowlist in `.gitignore`.

Machine-local overrides belong in ignored files such as terminal env overrides and `.config/nushell/local.env.nu`.
