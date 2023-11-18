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

