#!/usr/bin/env bash

get_mimetype() {
    # Caution: input filename should wrap in "" to avoid word splitting
    file -Lb --mime-type "$1"  # Follom symlink + brief output only
}
