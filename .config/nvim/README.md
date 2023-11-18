# TODO/deficiency

- Git workflow. Diffing and resolving conflicts are not intuitive with diffview. Fugitive is messy
- Jupyter notebook support
- Anything visual e.g. markdown preview (overcome by converting w/ pandoc), chatbot dialog

# Less common vim keymaps/tips

- `o` in visual mode let you "change end"
- `=` in visual mode let you re-indent the selected text
- Ex mode
    - `ex` is the predecessor of `vi`/`vim`. And commands such as 
    - ':s' for substitution. `:%s/<a>/<b>/gc` let you substitute in current buffer every occurence of `a` with `b` and ask for confirmation
    - `:g` for search. An example of powerful combination is `:g/sometext/y A` which yanks every occuerence of `sometext` into register `a`
    - `:m` for move
    - `:t` for duplicate
    - `:d` for delete
    - `:r` for read
    - `:y` for yank
Ranges in command line mode
    - `%` in cmdline is a shorthand for `1,$`, which targets the whole file
    - Interoperable with marks (see below)
    - `.` (?)
    - Relative to target by e.g. `-1`, `+2`
- Registers & macros
    - E.g. `"a`
    - Macros are stored inside register, so macros can be edited like text. Copy/paste are essentially macros and can interop.
    - `"+` and `"*` are system clipboards
- Marks
    - E.g. `'a`
    - `'<` and `'>` are marks that refers to start and end of selected area. E.g. `:'<,'>d` will delete the selected area. `'<,'>` is automatically appended to `:` when (visual mode) -> (cmdline)
- Filters
    - Contents of buffer can be piped to external programs with filters. Filter operation has the syntax `:<range>!<filter> <args>`. E.g. `:%!ls` performs `ls | vim -` in bash
    - You can append output of an external program into cursor position w/ `:r !<command>`. E.g. `:r !ls`
    - You can append content of a file to cursor position with `:r <file>`
- `g`
    - `gv` let you reselect last visual selection
    - `gi` let you enter insert mode in last insert position (where insert mode was last exited)
    - `gu`/`gU` are the uppercase/lowercase motion. E.g. `gUiw` will uppercase the entire word. `gUU` will uppercase the entire line
    - `gn`/`gN` are like `gv` but search forward/backward for the last search term (doesn't play well w/ flash unfortunately)
    - `gj`/`gk` to navigate between visual row (for wrapped lines)
- Append search term with `/e` to target the end rather the the beginning. E.g. `y/sometext/e`. See https://vimhelp.org/pattern.txt.html#search-offset
- `{` and `}` to navigate between blank lines
- While in insert mode, use `C-o` to do a normal mode command
- `zz`/`zt`/`zb` for center/top/bottom cursor against screen
- Jumplist
