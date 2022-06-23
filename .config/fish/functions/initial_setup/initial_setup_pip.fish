function initial_setup_pip
  set -l plugins \
    debugpy \
    qtconsole \
    mypy

  for plugin in $plugins
    pip3 install $plugin
  end
end
