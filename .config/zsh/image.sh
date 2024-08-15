#!/usr/bin/env bash

CACHE_IMAGEMAGICK_IMAGE=~/.cache/imagemagick-cache.jpg

# Get the thumbnail of PDf by its first page and return the path of the image
get_pdf_thumbnail_as_image() {
	convert -density 150 "$1[0]" -quality 90 "$CACHE_IMAGEMAGICK_IMAGE"
	echo "$CACHE_IMAGEMAGICK_IMAGE"
}

CACHE_FFMPEG_IMAGE=~/.cache/ffmpeg-cache.png

# Get the thumbnail of video by its frame at 00:00:05 and return the path of the image
get_video_thumbnail_as_image() {
	ffmpeg -i "$1" -ss 00:00:05 -vframes 1 -y $CACHE_FFMPEG_IMAGE
	echo "$CACHE_FFMPEG_IMAGE"
}

# Convert m3u8 (url or local) to mkv
convert_m3u8_to_mkv() {
	ffmpeg -i $1 -c copy $2
}

# Convert mkv to mp4
convert_mkv_to_mp4() {
	# https://askubuntu.com/questions/396883/how-to-simply-convert-video-files-i-e-mkv-to-mp4
	# If you only want to convert MKV to MP4 then you will save quality and a lot of time by just changing the containers.
	# Both of these are just wrappers over the same content so the CPU only needs to do a little work.
	# Don't re encode as you will definitely lose quality.
	ffmpeg -i $1 -c copy $2
}

# Convert webm to mp3
convert_webm_to_mp3() {
	ffmpeg -i $1 -vn -ar 44100 -ac 2 -b:a 192k $2
}

convert_pdf_to_image() {
	magick -density 300 "$1" -quality 100 "$2"
}

convert_pdf_to_single_image() {
	magick -density 300 "$1" -append -quality 100 "$2"
}
