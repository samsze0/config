#!/usr/bin/env bash

cat <<EOT >> ~/.gitconfig


[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    commit-style                  = raw
    file-style                    = yellow
    hunk-header-style             = bold
    minus-style                   = bold red
    minus-non-emph-style          = bold red
    minus-emph-style              = bold red "#362323"
    minus-empty-line-marker-style = normal "#362323"
    zero-style                    = normal
    plus-style                    = bold green
    plus-non-emph-style           = bold green
    plus-emph-style               = bold green "#1b3432"
    plus-empty-line-marker-style  = normal "#1b3432"
    grep-file-style               = blue
    grep-line-number-style        = blue
    whitespace-error-style        = reverse blue
    blame-palette                 = #000000 #222222 #444444
EOT