# Neovim FZF plugin

An unopinionated thin-wrapper around fzf

## IPC w/ Fzf

- Uses unix socket / UDP with a custom protocol for receiving messages emitted by fzf rather than using nvim rpc
