#!/usr/bin/env bash

# Wallpaper
swww init &
swww img ~/.config/wallpapers/osx-monterey.jpg &

# Network manager applet
nm-applet --indicator &

# Waybar
# waybar &

# Notifications
dunst &

# wl-clipboard + cliphist (a clipboard manager for wayland)
# https://github.com/sentriz/cliphist
wl-paste --watch cliphist store &

# Day/night gamma adjustments
# https://www.mankier.com/1/wlsunset
wlsunset -S "06:30" -s "18:30" -T 6500 -t 4600 &

# Input methods
fcitx5 &

# XRemap (for some reason needs to be restarted)
systemctl --user restart xremap
