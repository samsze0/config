# function initial_setup_kitty
#   # Generate kitty.conf if not already exist
#   if not test -f $KITTY_CONFIG_DIRECTORY/kitty.conf
#     cat $KITTY_CONFIG_DIRECTORY/_kitty.conf > $KITTY_CONFIG_DIRECTORY/kitty.conf

#     for color in $colors
#       set -l kv (string split ':' $color)
#       string replace --all (string upper $kv[1]) $kv[2] (cat $KITTY_CONFIG_DIRECTORY/kitty.conf) > $KITTY_CONFIG_DIRECTORY/kitty.conf
#     end
#   end
# end
