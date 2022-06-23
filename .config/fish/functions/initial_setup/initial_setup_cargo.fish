function initial_setup_cargo
  set -l plugins \
    zeta-note \
    toipe

  for plugin in $plugins
    cargo install $plugin
  end
end
