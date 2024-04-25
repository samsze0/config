#!/usr/bin/env bash

# shellcheck source=./browser.sh
source ~/.config/zsh/browser.sh

CACHE_PANDOC_PDF=~/.cache/pandoc-cache.pdf

# Open markdown in browser as pdf with predefined theme stoerd in `~/.config/pandoc/`
open_md_in_browser_as_pdf() {
	# TODO: fix text colors
	pandoc --pdf-engine=xelatex \
		-f markdown \
		-t pdf \
		--template ~/.config/pandoc/notion-dark.tex \
		$1 >$CACHE_PANDOC_PDF

	open_in_browser_new_window $CACHE_PANDOC_PDF
}

CACHE_PANDOC_HTML=~/.cache/pandoc-cache.html

# Open markdown in browser as html with predefined theme stoerd in `~/.config/pandoc/`
open_md_in_browser_as_html() {
	# https://pandoc.org/demos.html
	pandoc --standalone \
		--css ~/.config/pandoc/light.css \
		--katex \
		--highlight-style pygments \
		"$1" -o $CACHE_PANDOC_HTML

	open_in_browser_new_window $CACHE_PANDOC_HTML
}
