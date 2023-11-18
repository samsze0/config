#!/usr/bin/env bash

# Copy file to the tailscale inbox of targeted peer
tailscale_send() {
  DATA=$(tailscale status --json | gojq '.Peer | .[] | { HostName, TailscaleIPs, Online, Active }')
  PEERS=$(echo "$DATA" | gojq '.HostName')

  PEERS=${PEERS//\"/}

  P=$(echo "$PEERS" | fzf)
  sudo tailscale file cp "$@" "$P:"
}

# Get file from tailscale inbox to destination dir
tailscale_get() {
  sudo tailscale file get $@
}
