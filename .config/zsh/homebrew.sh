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
	brew info "$1" --json=v2 | gojq '.formulae | .[] | .name + "  Description: " + .desc + "  Version: " + .versions.stable + "  Installed-version: " + .installed[0].version' --raw-output
}

# Show info of a cask
brew_cask_info() {
	brew info "$1" --json=v2 | gojq '.casks | .[] | .name'
}

# Show all installed formulae w/ their descriptions
brew_formulae_info() {
	if false; then
		brew_formulae_list | xargs brew desc --eval-all
	fi
	brew_formuale_list | xargs brew_formula_info
}

# Show all installed casks w/ their descriptions
brew_casks_info() {
	if false; then
		brew_casks_list | xargs brew desc --eval-all
	fi
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

# pip freeze but for brew. Output *.brew files
brew_freeze() (
	set_flags

	if [ "$(arch)" = "i386" ]; then # Rosetta
		FORMULAE_FILE=~/formulae-x86.brew
		CASKS_FILE=~/casks-x86.brew
		TAPS_FILE=~/taps-x86.brew
	else # M1
		FORMULAE_FILE=~/formulae.brew
		CASKS_FILE=~/casks.brew
		TAPS_FILE=~/taps.brew
	fi

	brew_formulae_list >$FORMULAE_FILE

	# Empty the files
	echo "" >$TAPS_FILE
	echo "" >$CASKS_FILE

	for c in $(brew_casks_list); do
		TAP=$(brew info --casks "$c" --json=v2 | gojq ".casks[0] | .tap" --monochrome-output --raw-output)
		echo "$TAP" >>$TAPS_FILE
		echo "$c" >>$CASKS_FILE
	done >$CASKS_FILE
)

# pip install -r but for brew. Input *.brew files
brew_install_r() {
	if [ "$(arch)" = "i386" ]; then # Rosetta
		for f in $(cat ~/formulae-x86.brew); do
			brew install "$f"
		done
		for c in $(cat ~/casks-x86.brew); do
			brew install "$c"
		done
		# while read -r formula; do
		# 	brew install "$formula"
		# done <~/formulae-x86.brew
		# while read -r cask; do
		# 	brew install "$cask"
		# done <~/casks-x86.brew
	else # Apple silicon
		for f in $(cat ~/formulae.brew); do
			brew install "$f"
		done
		for c in $(cat ~/casks.brew); do
			brew install "$c"
		done
		# while read -r formula; do
		# 	brew install "$formula"
		# done <~/formulae.brew
		# while read -r cask; do
		# 	brew install "$cask"
		# done <~/casks.brew
	fi
}
