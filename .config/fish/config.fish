if status is-interactive
  # Non-OS specific

  set -gx colors $impinkneo

  set -gx EDITOR subl
  set -gx PAGER less

  set -l fish_version (string split -r -m1 ' ' (fish -v))[2]

  # Abbr

  abbr --add -g git_show_staged "git diff --staged --name-only"
  abbr --add -g git_remove_cached "git rm -r --cached (git ls-files -i -c --exclude-from=.gitignore)"
  
  abbr --add -g btm "btm --config ~/.config/btm/config.toml"

  # Keybind

  fish_default_key_bindings  # emacs-mode
  bind -k nul complete-and-search --user
  bind \t accept-autosuggestion --user

  # Recursively add subdirectories to function path

  for dir in (fd --type d . ~/.config/fish/functions)
    set -ga fish_function_path $dir
  end

  # TMUX

  if not set -q TMUX
    tmux attach-session 2> /dev/null
    if [ $status != 0 ]
      tmux new-session -n main -c ~ -s main
    end
  end

  # tmux source-file ~/.config/tmux/init.conf

  # OS specific

  if [ (uname) = "Darwin" ]
    # OSX
    set -gx fish_user_paths \
      /opt/homebrew/bin \
      /opt/homebrew/opt/openjdk/bin \
      /opt/homebrew/opt/sphinx-doc/bin \
      ~/bin \
      ~/.cargo/bin \
      /usr/local/bin \
      /usr/local/sbin

    set -g fish_function_path \
      ~/.config/fish/functions \
      /opt/homebrew/Cellar/fish/$fish_version/etc/fish/functions \
      /opt/homebrew/Cellar/fish/$fish_version/share/fish/functions \
      /opt/homebrew/share/fish/vendor_functions.d

    set -g fish_complete_path \
      ~/.config/fish/completions \
      ~/.local/share/fish/generated_completions \
      /opt/homebrew/Cellar/fish/$fish_version/etc/fish/completions \
      /opt/homebrew/Cellar/fish/$fish_version/share/fish/completions \
      /opt/homebrew/share/fish/vendor_completions.d

    if set -q KITTY_PID
      set -ga fish_function_path "/Applications/kitty.app/Contents/Resources/kitty/shell-integration/fish/vendor_functions.d"
      set -ga fish_complete_path "/Applications/kitty.app/Contents/Resources/kitty/shell-integration/fish/vendor_completions.d"
    end

  else if [ (uname) = "Linux" ]
    # Linux
    # set -gx fish_user_paths
    
  end
end

# pnpm
set -gx PNPM_HOME "/Users/mingsumsze/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end