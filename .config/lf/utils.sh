#!/usr/bin/env bash

set -eu

get_mimetype() {
    # Caution: input filename should wrap in "" to avoid word splitting
    file -Lb --mime-type "$1"  # Follom symlink + brief output only
}

CACHE_PANDOC_PDF=~/.cache/lf-open-tmp-pandoc.pdf

# open_md_as_pdf() {
#     # TODO: fix text colors
#     pandoc --pdf-engine=xelatex \
#       -f markdown \
#       -t pdf \
#       --template ~/.config/pandoc/notion-dark.tex \
#       $1 > $CACHE_PANDOC_PDF
#
#     firefox $CACHE_PANDOC_PDF
# }

CACHE_PANDOC_HTML=~/.cache/lf-open-tmp-pandoc.html

open_md_as_html() {
    # https://pandoc.org/demos.html
    pandoc --standalone \
      --css ~/.config/pandoc/light.css \
      --katex \
      --highlight-style pygments \
      $1 -o $CACHE_PANDOC_HTML

    firefox $CACHE_PANDOC_HTML
}
