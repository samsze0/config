function initial_setup_symlinks
  # Cloud
  cd ~
  if not test -L cloud
    ln -s "Library/Mobile Documents/com~apple~CloudDocs/" cloud
  end

  # # Sioyek
  # cd "/Applications/sioyek.app/Contents/MacOS/"
  # if not test -L prefs.config
  #   ln -s ~/.config/sioyek/prefs.config
  # end
  # if not test -L keys.config
  #   ln -s ~/.config/sioyek/keys.config
  # end

  # # Calcurse
  # mkdir -p ~/.local/share/calcurse
  # cd ~/.local/share/calcurse
  # if not test -L apts
  #   ln -s ~/cloud/calcurse/apts
  # end
  # if not test -L todo
  #   ln -s ~/cloud/calcurse/todo
  # end

  # Min Browser
  cd ~/Library/Application\ Support/Min
  if not test -L settings.json
    ln -s ~/cloud/min/settings.json
  end
  if not test -L bookmarksBackup.html
    ln -s ~/cloud/min/bookmarksBackup.html
  end

  # Ranger

  # Sublime text & merge
  ln -s /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl ~/bin/subl
  ln -s ~/.local/st/User /Library/Application\ Support/Sublime\ Text/Packages
  ln -s /Applications/Sublime\ Merge.app/Contents/SharedSupport/bin/smerge ~/bin/smerge
end
