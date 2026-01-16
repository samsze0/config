# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for macOS. Uses an inverted gitignore pattern (ignore everything, then whitelist specific configs). Run `git ls-files` to see all tracked files.

## Tracked Configurations

- **Shell:** Nushell (`.config/nushell/`), Zsh (`.zshrc`, `.config/zsh/`)
- **Editors:** Zed (`.config/zed/`)
- **Terminal:** Kitty (`.config/kitty/`), tmux (`.tmux.conf`)
- **Window manager:** AeroSpace (`.aerospace.toml`)
- **Tools:** Yazi (`.config/yazi/`), Karabiner (`.config/karabiner/`), starship (`.config/starship.toml`)
- **Package management:** Homebrew bundles (`.config/brew-bundles/`)
- **Docs:** `README.md`, `OSX.md`

## macOS Setup

```bash
# Install Homebrew packages (interactive bundle selector)
brew-bundle-install

# Configure Karabiner
cd ~/.config/karabiner && npx tsx config.ts
```

## Architecture Notes

Configs handle both Apple Silicon and Intel/Rosetta. Homebrew prefix changes based on architecture (`/opt/homebrew` for arm64, `/opt/homebrew-x86` for x86_64).

## Git Configuration

- Git profiles stored in `$XDG_DATA_HOME/git-profiles/` (use `git-profile-set` to switch)
- Delta configured for diff syntax highlighting (see `.gitconfig`)

## MCP Launchpad  (Your gateway to ALL MCPs!)

You have access to the MCP Launchpad (`mcpl`), a unified CLI for discovering and executing tools from multiple MCP servers. The user may configure and change their MCP configuration at any time. So if your task requires a tool or functionality outside of your current capabilities, it's critical that you always check the MCP Launchpad for available tools that may be useful.

### Important: Always Discover Before Calling

Tool names vary between MCP servers. **Never guess tool names** - always discover them first.

If you're unsure of the tool name, **always search first**. The `mcpl search` command is the most efficient way to find relevant tools across all MCP servers.

#### Recommended Workflow

1. **Search first** to find the right tool (shows required params):
   ```bash
   mcpl search "list projects"
   ```

2. **Call with required params**:
   ```bash
   mcpl call vercel list_projects '{"teamId": "team_xxx"}'
   ```

#### Alternative: List Server Tools

If you know which server to use but not the tool name:
```bash
mcpl list vercel    # Shows all tools with required params
```

#### Get Example Calls

For complex tools, use `inspect --example` to get a ready-to-use example:
```bash
mcpl inspect sentry search_issues --example
# Shows: mcpl call sentry search_issues '{"organizationSlug": "<organizationSlug>", ...}'
```

### Error Recovery

If a tool call fails, mcpl provides helpful suggestions:

- **Tool not found**: Shows similar tool names from that server
- **Missing parameters**: Shows required params and an example call
- **Validation errors**: Shows expected parameter types

#### Troubleshooting Commands

```bash
mcpl verify                 # Test all server connections
mcpl session status         # Check daemon and server connection status
mcpl session stop           # Restart daemon (stops current, auto-restarts on next call)
mcpl config                 # Show current configuration
mcpl call <server> <tool> '{}' --no-daemon  # Bypass daemon for debugging
```

#### Common Issues

- **Server not connecting**: Run `mcpl verify` to test connections
- **Stale connections**: Run `mcpl session stop` then retry
- **Timeout errors**: Server may be slow; increase with `MCPL_CONNECTION_TIMEOUT=120`

### Quick Reference

```bash
# Show help
mcpl --help

# Find tools
mcpl search "<query>"                    # Search all tools (shows required params, returns 5 by default)
mcpl search "<query>" --limit 10         # Get more results
mcpl list                                # List all MCP servers
mcpl list <server>                       # List tools for a server (shows required params)

# Get tool details
mcpl inspect <server> <tool>             # Full schema
mcpl inspect <server> <tool> --example   # Schema + example call

# Execute tools
mcpl call <server> <tool> '{}'                        # No arguments
mcpl call <server> <tool> '{"param": "value"}'        # With arguments

# Verify servers
mcpl verify                              # Test all servers are working
```