# function notes_add_asset
#   # Use kitty icat w/ --transfer-mode=file ? tmux fork ? 
#   set -l preview_cmd (printf "\
#     set -l ext (string split -r -m1 '.' {})[2]
#     if test ([ \$ext = 'mov' ]) -o ([ \$ext = 'gif' ]) -o ([ \$ext = 'svg' ])
#       rm ~/Downloads/.tmp.png
#       convert ~/Downloads/{}[1] ~/Downloads/.tmp.png
#       if set -q TMUX
#         viu ~/Downloads/.tmp.png
#       else
#         kitty icat --silent --clear --place 200x40@0x0 --transfer-mode file ~/Downloads/.tmp.png
#       end
#     else
#       if set -q TMUX
#         viu ~/Downloads/{}
#       else
#         kitty icat --silent --clear --place 200x40@0x0 --transfer-mode file ~/Downloads/{}
#       end
#     end)
#   ")

#   # set -l asset (ls ~/Downloads | rg '.jpeg|.svg|.png|.jpg|.mp4|.mov|.gif' | fzf --tac --preview="kitty icat ~/Downloads/{}" --preview-window=bottom,wrap,80%)
#   set -l asset (ls ~/Downloads | rg '.jpeg|.svg|.png|.jpg|.mp4|.mov|.gif' | fzf --tac)

#   if test -z $asset
#     return 0
#   end

#   set -l ext (string split -r -m1 '.' $asset)[2]

#   read -l name

#   if test -z $name
#     return 0
#   end

#   set -l topic (printf (string join '\n' (ls ~/cloud/notes)) | fzf)

#   if test -z $topic
#     return 0
#   end

#   mv ~/Downloads/$asset ~/cloud/notes/$topic/assets/$name.$ext
# end
