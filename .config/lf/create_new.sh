#!/usr/bin/env bash

for f in $@; do
  if [[ $f =~ .*/$ ]]; then  # If ends in "/". regex requires [[]]
    mkdir -p $f
  else
    touch $f  # Doesn't create the parent dir for the file
  fi
done
