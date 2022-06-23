function command_prompt
  set -l cmd (functions --names | fzf)
  eval $cmd
end
