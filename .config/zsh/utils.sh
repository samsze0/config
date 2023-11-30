#!/usr/bin/env bash

# Return mimetype of input
get_mimetype() {
	# Caution: input filename should wrap in "" to avoid word splitting
	file -Lb --mime-type "$1" # Follom symlink + brief output only
}

# Check if command exists. If not, exit with 1
check_command_exists() {
	if command -v $1 >/dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

# Log out all programs instead of the first match only
which_all() {
	for dir in $(echo "$PATH" | tr ":" " "); do
		find "$dir" -maxdepth 1 -name 'nc' -executable -type f,l 2>/dev/null
		# Type is file or symlink (becaues of NixOS). Redirect any error to /dev/null in case dir doesn't exist
	done
}

set_flags() {
	set -o errexit
	set -o nounset
	set -o pipefail
}

unset_flags() {
	set +o errexit
	set +o nounset
	set +o pipefail
}
