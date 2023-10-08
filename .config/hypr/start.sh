#!/usr/bin/env bash

# Wallpaper
swww init &
swww img ~/Desktop/Desktop-background/sand-wave.jpg &

# Network manager applet
nm-applet --indicator &

# Waybar
waybar &

# Notifications
dunst