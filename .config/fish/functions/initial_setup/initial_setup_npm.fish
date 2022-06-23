function initial_setup_npm
  set -l plugins \
    typescript \
    vim-language-server \
    live-server \
    typescript-language-server \
    terminalizer

  for plugin in $plugins
    yarn global add $plugin
  end
end
