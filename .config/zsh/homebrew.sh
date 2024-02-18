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
	else # M1
		FORMULAE_FILE=~/formulae.brew
		CASKS_FILE=~/casks.brew
	fi

	brew_formulae_list >$FORMULAE_FILE

	CASK_TOKENS=$(brew_taps_cask_token_list)

	for c in $(brew_casks_list); do
		TAP=$(brew info --casks "$c" --json=v2 | gojq ".casks[0] | .tap" --monochrome-output --raw-output)
		echo "$TAP/$c"
	done >$CASKS_FILE

	if false; then
		for c in $(brew_casks_list); do
			results=$(echo "$CASK_TOKENS" | rg "$c")
			num_results=$(echo results | wc -l)
			if (($num_results > 1)); then
				echo >&2 "Ambiguous cask token for $c"
				exit 1
			elif (($num_results == 1)); then
				echo "$results" | head -n 1
			else
				echo "$c"
			fi
		done >$CASKS_FILE
	fi
)

# Custom brew install that updates *.brew
brew_install() {
	brew install $@
	brew_freeze
}

# Custom brew uninstall that updates *.brew
brew_uninstall() {
	brew uninstall $@
	brew_freeze
}

# pip install -r but for brew. Input *.brew files
brew_install_from() {
	if [ "$(arch)" = "i386" ]; then # Rosetta
		cat ~/formulae-x86.brew | xargs brew install
		cat ~/casks-x86.brew | xargs brew install --cask
	else # M1
		cat ~/formulae.brew | xargs brew install
		cat ~/casks.brew | xargs brew install --cask
	fi
}
