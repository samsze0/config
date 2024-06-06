#!/usr/bin/env bash

# Show all installed formulae
brew_formulae_list() {
	brew leaves --installed-on-request -v
}

# Show all installed casks
brew_casks_list() {
	brew ls --casks -1 --full-name
}

# Show info of a formula
brew_formula_info() {
	if [ -z "$1" ]; then
		echo "Usage: brew_formula_info <formula>"
		return 1
	fi

	brew info "$1" --json=v2 | gojq '.formulae | .[] | .name + "  Description: " + .desc + "  Version: " + .versions.stable + "  Installed-version: " + .installed[0].version' --raw-output
}

# Show info of a cask
brew_cask_info() {
	if [ -z "$1" ]; then
		echo "Usage: brew_cask_info <cask>"
		return 1
	fi

	brew info "$1" --json=v2 | gojq '.casks | .[] | .name'
}

# Show all installed formulae w/ their descriptions
brew_formulae_info() {
	brew_formulae_list | xargs brew_formula_info
}

# Show all installed casks w/ their descriptions
brew_casks_info() {
	brew_casks_list | xargs brew_cask_info
}

# Show all installed taps
brew_taps_list() {
	brew tap-info --installed --json | gojq '.[] | .name' --monochrome-output --raw-output
}

# Show list of all casks tokens provided by installed taps
brew_taps_cask_token_list() {
	brew tap-info --installed --json | gojq '.[] | .cask_tokens | flatten[]' --monochrome-output --raw-output
}

brew_dump() {
	brew bundle dump --global --force
}

brew_check() {
	brew bundle check --global
}

brew_cleanup() {
	brew bundle cleanup --global
}

brew_install() {
	brew bundle install --global
}