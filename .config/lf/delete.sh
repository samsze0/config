#!/usr/bin/env bash

set -f # disable filename expansion

declare -a files

trash_mode=false

while (("$#")); do
	case "$1" in
	--trash)
		trash_mode=true
		shift
		;;
	*)
		files+=("$1")
		shift
		;;
	esac
done

for f in "${files[@]}"; do
	if [ ! -e $f ]; then
		echo "file not found: $f"
		exit 1
	fi
	echo $f
done

echo ""

if $trash_mode; then
	printf "Trash? [y/n] "
	read ans
	[ $ans = "y" ] && trash ${files[@]}
else
	printf "Delete? [y/n] "
	read ans
	[ $ans = "y" ] && rm -rf ${files[@]}
fi
