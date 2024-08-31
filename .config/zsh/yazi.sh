#!/usr/bin/env bash

# Tail yazi log
# https://yazi-rs.github.io/docs/plugins/overview/#logging
yazi_log_tail() {
  tail -f ~/.local/state/yazi/yazi.log
}
