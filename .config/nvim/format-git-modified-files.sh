#!/usr/bin/env bash

GIT_DIR=$(git rev-parse --show-toplevel)
CONFIG_FILE=./stylua.toml

FILES=$(git diff --name-only)

for file in $FILES; do
  if [[ $file == *.lua ]]; then
    stylua -f $CONFIG_FILE "$GIT_DIR/$file"
  fi
done

UNTRACKED_FILES+=$(git ls-files --full-name --others --exclude-standard)

for file in $UNTRACKED_FILES; do
  if [[ $file == *.lua ]]; then
    stylua -f $CONFIG_FILE "$GIT_DIR/$file"
  fi
done