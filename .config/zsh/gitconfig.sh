#!/usr/bin/env bash

# Append settings to `.gitconfig`. Require manual removal of old entries.
gitconfig_init() {
cat <<EOT >> ~/.gitconfig

[diff]
    tool = nvimdiff

[difftool]
    prompt = false

[difftool "nvimdiff"]
    cmd = "nvim -d \\"\$LOCAL\\" \\"\$REMOTE\\""

[merge]
    tool = nvimdiff

[mergetool]
    prompt = true

[mergetool "nvimdiff"]
    cmd = "nvim -d \\"\$LOCAL\\" \\"\$REMOTE\\" \\"\$MERGED\\" -c 'wincmd w' -c 'wincmd J'"

[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    # Tweaked from: https://github.com/maxfangx
    # https://github.com/dandavison/delta/blob/main/themes.gitconfig
    # General appearance
    dark = true
    syntax-theme = base16
    # File
    file-style = "#cbd1da" bold
    file-added-label = [+]
    file-copied-label = [==]
    file-modified-label = [*]
    file-removed-label = [-]
    file-renamed-label = [->]
    file-decoration-style = "#3e4451" ul
    file-decoration-style = "#727b8f" ul
    # No hunk headers
    hunk-header-style = omit
    # Line numbers
    line-numbers = true
    line-numbers-left-style = "#727b8f"
    line-numbers-right-style = "#727b8f"
    line-numbers-minus-style = "#c64d4d"
    line-numbers-plus-style = "#537dcd"
    line-numbers-zero-style = "#727b8f"
    line-numbers-left-format = " {nm:>3} │"
    line-numbers-right-format = " {np:>3} │"
    # Diff contents
    inline-hint-style = syntax
    minus-style = syntax "#2f0f0f"
    minus-emph-style = syntax "#7b2525"
    minus-non-emph-style = syntax auto
    plus-style = syntax "#122241"
    plus-emph-style = syntax "#26498b"
    plus-non-emph-style = syntax auto
    whitespace-error-style = "#7b2525" reverse
    # Commit hash
    commit-decoration-style = normal box
    commit-style = "#cbd1da" bold
    # Blame
    blame-code-style = syntax
    blame-format = "{author:>18} ({commit:>8}) {timestamp:<13} "
    blame-palette = "#000000" "#1d2021" "#282828" "#3c3836"
    # Merge conflicts
    merge-conflict-begin-symbol = ⌃
    merge-conflict-end-symbol = ⌄
    merge-conflict-ours-diff-header-style = "#e9a069" bold
    merge-conflict-theirs-diff-header-style = "#e9a069" bold overline
    merge-conflict-ours-diff-header-decoration-style = ''
    merge-conflict-theirs-diff-header-decoration-style = ''
EOT
}
