function tmux_kill
  set -l keys (string split '' "abcdefghijklmnopqrstuvwxyz")
  set -l sessions (tmux list-sessions -F "#S")
  set -l menu ""
  for i in (seq (count $sessions))
    set -a menu "$sessions[$i]" $keys[$i] "run -b 'tmux kill-session -t $sessions[$i]'"
  end
  tmux display-menu -T "Kill session" -x C -y C \
    $menu \
    "" \
    "Quit" q ""
end
