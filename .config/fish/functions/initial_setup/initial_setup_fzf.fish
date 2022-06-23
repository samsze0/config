function initial_setup_fzf
  for color in $colors
    set -l kv (string split ':' $color)
    # set -l $kv[1] $kv[2]
    eval "set -l $kv[1] $kv[2]"
  end

  set -l color (string join , \
   bg+:$black \
   bg:$black \
   spinner:$blue \
   hl:$yellow \
   fg:$graylight \
   header:$yellow \
   info:$yellow \
   pointer:$blue \
   marker:$blue \
   fg+:$white \
   prompt:$yellow \
   hl+:$yellow)

  set -Ux FZF_DEFAULT_OPTS "--no-bold --color=$color"
end
