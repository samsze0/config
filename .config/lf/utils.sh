#!/usr/bin/env bash

set -eu

get_mimetype() {
    # Caution: input filename should wrap in "" to avoid word splitting
    file -Lb --mime-type "$1"  # Follom symlink + brief output only
}
