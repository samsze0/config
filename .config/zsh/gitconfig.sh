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
    side-by-side                  = false
    line-numbers                  = false
    commit-style                  = raw
    file-style                    = white
    hunk-header-style             = bold
    minus-style                   = bold red
    minus-non-emph-style          = bold red
    minus-emph-style              = bold red "#2f0f0f"
    minus-empty-line-marker-style = normal "#2f0f0f"
    zero-style                    = normal
    plus-style                    = bold green
    plus-non-emph-style           = bold green
    plus-emph-style               = bold green "#122241"
    plus-empty-line-marker-style  = normal "#122241"
    grep-file-style               = blue
    grep-line-number-style        = blue
    whitespace-error-style        = reverse blue
    blame-palette                 = #000000 #222222 #444444
EOT
}
