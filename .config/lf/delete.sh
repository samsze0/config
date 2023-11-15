#!/usr/bin/env bash

set -f
for f in $@; do
    if [ ! -e $f ]; then
        echo "file not found: $f"
        exit 1
    fi
    echo $f
done
echo ""
printf "delete? [y/n] "
read ans
[ $ans = "y" ] && rm -rf $@
