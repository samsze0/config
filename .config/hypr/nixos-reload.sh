#!/usr/bin/env bash

NOTIFICATION_DURATION=${1:-2000}  # Fallback to 2000ms

sudo nixos-rebuild switch --flake ~/nixos-config || dunstify "Fail to reload NixOS config" -t $NOTIFICATION_DURATION

dunstify "NixOS config reloaded" -t $NOTIFICATION_DURATION