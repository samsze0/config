# AGENTS.md

Guidance for coding agents working in this personal dotfiles repository.

## Repository Overview

This is a macOS-first dotfiles repository with best-effort Linux support for shared shell, editor, terminal, and tool configuration. The repo uses an inverted `.gitignore`: everything is ignored by default, then specific files and directories are allowlisted.

Always use `git ls-files` as the source of truth for what is part of version control. There may be many local config files under `$HOME` that are intentionally untracked.

## Scope Rules

- Inspect `git ls-files` before making broad cleanup or documentation changes.
- Only edit tracked files unless the user explicitly asks to add or modify untracked files.
- Preserve existing dirty worktree changes. If a tracked file already has local edits, read it carefully and work with those edits rather than overwriting them.
- Do not commit secrets, machine-local state, generated caches, histories, or private app config.
- Keep macOS behavior first-class, but avoid breaking Linux branches in shared configs.

## Tracked Configuration Areas

- **Shell:** Nushell in `.config/nushell/`, Zsh entrypoint in `.zshrc`
- **Terminal:** Kitty, Ghostty, tmux
- **Editors:** Zed project and user settings
- **Window management:** AeroSpace
- **Tools:** Yazi, Karabiner-Elements, Starship, bat, bottom, Topiary, PulseAudio, tmuxinator
- **Package management:** Homebrew bundles in `.config/brew-bundles/`
- **Docs:** `README.md`, `OSX.md`, `AGENTS.md`

Do not assume untracked directories, such as local Neovim or Zsh plugin directories, are part of the repo unless they appear in `git ls-files`.

## Platform Notes

macOS is the primary setup target. Homebrew bundle management, Karabiner generation, AeroSpace, and macOS defaults belong to that path.

Linux support is best effort for tracked shared configs. Current tracked files include Linux-aware Nushell setup, Linux prompt metadata in Starship, and a Linux tmuxinator profile. The complete Linux system configuration lives separately in the NixOS repo linked from `README.md`.

## Common Commands

```bash
# Show the tracked repository surface
git ls-files

# Check local modifications before editing
git status --short

# Install Homebrew packages from an interactive bundle selector
brew-bundle-install

# Regenerate Karabiner config from the tracked TypeScript source
cd ~/.config/karabiner && bun run generate

# Regenerate Starship config from the tracked TypeScript source
cd ~/.config/starship && bun run generate
```

When changing generated configuration, update the source generator and the generated tracked output together when both are tracked.
