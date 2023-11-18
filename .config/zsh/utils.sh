#!/usr/bin/env bash

# Return mimetype of input
get_mimetype() {
    # Caution: input filename should wrap in "" to avoid word splitting
    file -Lb --mime-type "$1"  # Follom symlink + brief output only
}

# Check if command exists. If not, exit with 1
check_command_exists() {
    if command -v $1 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}
