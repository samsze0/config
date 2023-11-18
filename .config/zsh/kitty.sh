#!/usr/bin/env bash

# Save kitty session
kitty-save-session() {
    kitty @ ls | python ~/.config/kitty/kitty-convert-dump.py > ~/.config/kitty/session
}

# Spawn a kitty instance as child process with session specified
kitty-load-session() {
    kitty --session ~/.config/kitty/session
}
