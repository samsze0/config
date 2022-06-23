function initial_setup_fish_colors
  for color in $colors
    set -l kv (string split ':' $color)
    # set -l $kv[1] $kv[2]
    eval "set -l $kv[1] $kv[2]"
  end

  # colors
  set -Ux fish_color_autosuggestion $graylight
  set -Ux fish_color_command $blue
  set -Ux fish_color_cwd $blue
  set -Ux fish_color_comment $graylight
  set -Ux fish_color_cwd_root $yellow
  set -Ux fish_color_end $yellow
  set -Ux fish_color_error $red
  set -Ux fish_color_escape $blue
  set -Ux fish_color_match $red
  set -Ux fish_color_operator $yellow
  set -Ux fish_color_param $white
  set -Ux fish_color_quote $yellow
  set -Ux fish_color_redirection $yellow
  set -Ux fish_color_search_match "--background=$graymedium"
  set -Ux fish_color_search_selection "--background=$graymedium"
  set -Ux fish_color_normal $white
  set -Ux fish_color_status $red
  set -Ux fish_color_user $blue
  set -Ux fish_color_selection $white
  set -Ux fish_color_history_current "--bold"
  set -Ux fish_color_cancel "-r"
  set -Ux fish_color_host "normal --bold"
  set -Ux fish_color_valid_path "--bold"
  set -Ux fish_pager_color_description $white
  set -Ux fish_pager_color_completion "normal"
  set -Ux fish_pager_color_prefix "normal --bold"
  set -Ux fish_pager_color_progress $blue
  set -Ux fish_color_host_remote $yellow

  set -Ux pure_color_danger $red
  set -Ux pure_color_info $blue
  set -Ux pure_color_light $white
  set -Ux pure_color_mute $graylight
  set -Ux pure_color_dark $black
  set -Ux pure_color_primary $blue
  set -Ux pure_color_success $blue
  set -Ux pure_color_warning $yellow
  set -Ux pure_color_normal	"normal"
end
