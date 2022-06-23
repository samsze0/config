function initial_setup_fish
  # fisher
  curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher

  set -l plugins \
    jethrokuan/z \
    pure-fish/pure

  for plugin in $plugins
    fisher install $plugin
  end
end
