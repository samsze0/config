function python_venv_interactive
  set -l PYTHON_VENV_DIRECTORY ~/dev/venv

  set -l venvs (ls $PYTHON_VENV_DIRECTORY)
  set -l choice (printf (string join '\n' \
    $venvs \
    create \
    deactivate \
    ) | fzf)

  echo $choice

  switch "$choice"
  case ""
    return 0

  case "create"
    read -l venv
    python3 -m venv $PYTHON_VENV_DIRECTORY/$venv

  case "deactivate"
    deactivate

  case "*"
    set -l choice2 (printf (string join \
      delete \
      activate \
    ) | fzf)

    switch "$choice2"
    case ""
      return 0
    case "delete"
      rm -r $PYTHON_VENV_DIRECTORY/$choice
    case "activate"
      source $PYTHON_VENV_DIRECTORY/$choice/bin/activate.fish
    end
  end
end
