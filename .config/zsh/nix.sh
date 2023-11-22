#!/usr/bin/env bash

# Restart xremap as systemctl user service
xremap_restart() {
  systemctl --user restart xremap
}
