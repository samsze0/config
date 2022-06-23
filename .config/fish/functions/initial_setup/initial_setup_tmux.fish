# function initial_setup_tmux
#   # Generate tmux/setting.conf if not already exist
#   if not test -f $TMUX_CONFIG_DIRECTORY/setting.conf
#     cat $TMUX_CONFIG_DIRECTORY/_setting.conf > $TMUX_CONFIG_DIRECTORY/setting.conf

#     for color in $colors
#       set -l kv (string split ':' $color)
#       string replace --all (string upper $kv[1]) $kv[2] (cat $TMUX_CONFIG_DIRECTORY/setting.conf) > $TMUX_CONFIG_DIRECTORY/setting.conf
#     end
#   end
# end
