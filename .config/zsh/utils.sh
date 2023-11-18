#!/usr/bin/env bash

# Return mimetype of input
get_mimetype() {
    # Caution: input filename should wrap in "" to avoid word splitting
    file -Lb --mime-type "$1"  # Follom symlink + brief output only
}
