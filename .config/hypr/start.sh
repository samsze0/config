#!/usr/bin/env bash

# Environment variables

# XDG
# A project to work on interoperability and shared base technology for desktop environments for the X Window System (X11) and Wayland on Linux and other Unix-like OS.
# Example projects include wayland itself, poppler (PDF rendering library), cairo (vector graphics library), D-Bus (system process message bus), systemd (init framework), PipeWire.
# https://en.wikipedia.org/wiki/Freedesktop.org
# export XDG_CURRENT_DESKTOP=Hyprland
# export XDG_SESSION_TYPE=wayland
# export XDG_SESSION_DESKTOP=Hyprland

# GTK
# GTK (formerly GIMP ToolKit and GTK+) is a widget toolkit for creating GUIs (similar to Qt).
# GDK is the low-level library used by GTK to interact with the windowing system for graphics and input devices
# export GDK_BACKEND=wayland,x11

# export SDL_VIDEODRIVER=wayland

# Clutter
# A library for doing animations and using a 2.5D canvas.
# A number of third-party libraries allow integration with other technologies, e.g. Clutter-GTK.
# https://developer-old.gnome.org/platform-overview/unstable/tech-clutter.html.en
# https://en.wikipedia.org/wiki/Clutter_(software)#:~:text=Clutter%20is%20an%20OpenGL%2Dbased,2D%20graphics%20rendering%20using%20Cairo.
# export CLUTTER_BACKEND=wayland

# winit
# Cross-platform window creation and management in Rust.
# https://github.com/rust-windowing/winit
# export WINIT_UNIX_BACKEND=wayland

# Qt
# export QT_AUTO_SCREEN_SCALE_FACTOR=1
# export QT_QPA_PLATFORM="wayland;xcb"
# export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# wlroots
# A modular Wayland compositor library.
# It provides several powerful, standalone, and optional tools that implement components common to many compositors.
# https://gitlab.freedesktop.org/wlroots/wlroots/-/blob/master/docs/env_vars.md
# export WLR_DRM_NO_MODIFIERS=1

# DRM (Direct rendering manager)
# A subsystem of the Linux kernel responsible for interfacing with GPUs of modern video cards.
# DRM exposes an API that user-space programs can use to send commands and data to the GPU and perform operations.
# DRM was first developed as the kernel-space component of the X Server Direct Rendering Infrastructure, but
# since then it has been used by other graphic stack alternatives e.g. Wayland and standalone applications and libraries e.g. SDL2.
# DRM is also capable of GPGPU programing.
# https://en.wikipedia.org/wiki/Direct_Rendering_Manager

# GNOME Keyring
# export GNOME_KEYRING_CONTROL="/run/user/1000/keyring"
# export SSH_AUTH_SOCK="/run/user/1000/keyring/ssh"

# D-Bus
# dbus-update-activation-environment --all
# dbus-run-session -- Hyprland

# Wallpaper
swww init &
swww img ~/Desktop/Desktop-background/sand-wave.jpg &

# Network manager applet
nm-applet --indicator &

# Waybar
waybar &

# Notifications
dunst

# GNOME Keyring
# gnome-keyring-daemon --start --components=ssh,secrets,pkcs11
# /usr/libexec/polkit-gnome-authentication-agent-1

# Day/night gamma adjustments
# https://www.mankier.com/1/wlsunset
# wlsunset -S "06:30" -s "18:30" -T 6500 -t 4600

# MPD
# Music daemon
# https://www.musicpd.org/
# https://nixos.wiki/wiki/MPD
# mpd

# Thunar (file manager)
# thunar --daemon

# Xsettingsd
# A xsettings daemon which provides settings to Xorg applications via the XSETTINGS specification.
# https://wiki.archlinux.org/title/Xsettingsd

# Key remapper
# sudo xremap ~/.config/xremap/config.yml

# wl-clipboard + cliphist (a clipboard manager for wayland)
# https://github.com/sentriz/cliphist
wl-paste --watch cliphist store
