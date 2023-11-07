Use `dconf` to load config i.e. `dconf load /org/gnome/<schema> < config.conf`

e.g.
```shell
dconf load /org/gnome/desktop/wm/ < ~/.config/gnome/wm.conf
dconf load /org/gnome/shell/ < ~/.config/gnome/shell.conf
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ~/.config/gnome/media-keys.conf
dconf load /org/gnome/desktop/interface/ < ~/.config/gnome/desktop-interface.conf
dconf load /org/gnome/a11y/keyboard/ ~/.config/gnome/a11y-keyboard.conf
dconf load /org/gnome/peripherals/keyboard/ < ~/.config/gnome/peripherals-keyboard.conf
```

Use `dconf dump` to dump existing settings to `config`
