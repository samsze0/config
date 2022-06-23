# function initial_setup_nvim
#   # Packer
#   if not test -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim
#     git clone --depth 1 https://github.com/wbthomason/packer.nvim \
#       ~/.local/share/nvim/site/pack/packer/start/packer.nvim
#   end

#   # Generate colorscheme in Lua if not already exist
#   # if not test -f ~/.config/nvim/lua/colors/$colorscheme.lua
#   #   cat ~/.config/nvim/lua/colors/base.lua > ~/.config/nvim/lua/colors/$colorscheme.lua

#   #   for color in $colors
#   #     set -l kv (string split ':' $color)
#   #     string replace --all (string upper $kv[1]) $kv[2] (cat ~/.config/nvim/lua/colors/$colorscheme.lua) > ~/.config/nvim/lua/colors/$colorscheme.lua
#   #   end
#   # end
# end
