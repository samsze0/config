#!/usr/bin/env bash

set -eu

USE_CHAFA=false

# shellcheck source=../zsh/utils.sh
source ~/.config/zsh/utils.sh

# shellcheck source=../zsh/image.sh
source ~/.config/zsh/image.sh

get_filename() {
	# Split the input into an array
	local input=($@)

	# Get the length of the array
	local length=${#input[@]}

	# Calculate the new length by subtracting 4
	local new_length=$((length - 4))

	# Get the first 'new_length' elements of the array
	local stripped=("${input[@]:0:$new_length}")

	# Join the filename parts with " "
	local IFS=" "
	echo "${stripped[*]}"
}

get_image_coord() {
	# Split the input into an array
	local input=($@)

	echo "${input[-4]}x${input[-3]}@${input[-2]}x${input[-1]}"
}

get_image_size() {
	# Split the input into an array
	local input=($@)

	echo "${input[-4]}x${input[-3]}" # FIX
}

FILE=$(get_filename "$@")
IMAGE_COORDINATES=$(get_image_coord "$@")
IMAGE_SIZE=$(get_image_size "$@")

image_preview() {
	if $USE_CHAFA; then
		chafa -s $IMAGE_SIZE "$1" </dev/null >/dev/tty
	else
		kitty +kitten icat --transfer-mode file --stdin no --place $IMAGE_COORDINATES "$1" </dev/null >/dev/tty
	fi
}

MIME_TYPE=$(get_mimetype "$FILE")

if [[ $MIME_TYPE =~ ^image ]]; then
	image_preview "$FILE"
	exit 1
elif [[ $MIME_TYPE =~ ^text || $MIME_TYPE = application/json || $MIME_TYPE = application/javascript || $MIME_TYPE = application/octet-stream ]]; then
	bat --color always $FILE
	exit 1
elif [[ $MIME_TYPE =~ ^video ]]; then
	image_preview $(get_video_thumbnail_as_image "$FILE")
	exit 1
elif [[ $MIME_TYPE = application/pdf ]]; then
	image_preview $(get_pdf_thumbnail_as_image "$FILE")
	exit 1
else
	echo "$MIME_TYPE preview not supported"
	exit 1
fi
