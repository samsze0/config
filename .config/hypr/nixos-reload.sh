#!/usr/bin/env bash -e

NOTIFICATION_DURATION=${1:-2000}  # Fallback to 2000ms

sudo nixos-rebuild switch --flake ~/nixos-config

dunstify "NixOS config reloaded" -t $NOTIFICATION_DURATION