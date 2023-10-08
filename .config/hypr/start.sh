#!/usr/bin/env bash

# Wallpaper
swww init &
swww img ~/Desktop/Desktop-background/mac-bg.jpg &

# Network manager applet
nm-applet --indicator &

# Waybar
waybar &

# Notifications
dunst