#!/usr/bin/env bash

tailscale_send() {
  DATA=$(tailscale status --json | gojq '.Peer | .[] | { HostName, TailscaleIPs, Online, Active }')
  PEERS=$(echo "$DATA" | gojq '.HostName')

  PEERS=${PEERS//\"/}

  P=$(echo "$PEERS" | fzf)
  sudo tailscale file cp "$@" "$P:"
}
