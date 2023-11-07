Use `dconf` to load config i.e. `dconf load /org/gnome/<schema> < config.conf`

e.g.
```shell
dconf load /org/gnome/desktop/wm/ < ~/.config/gnome/wm.conf
dconf load /org/gnome/shell/keybindings/ < ~/.config/gnome/shell.conf
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ~/.config/gnome/media-keys.conf
```

Use `dconf dump` to dump existing settings to `config`
