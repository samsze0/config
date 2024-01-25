# Keymap

```
Fn->fuzzy/git/panels
Q-. W->window E-> R->replace T->tab Y-. U-. I-. O-. P-. [->jump ]->jump \->leader-misc
A-. S->hunk D-. F->search G-. H-> J-> K-> L->lsp ;-> '->
Z-. X->git C-. V-. B-> N-> M-> ,->macro .-. /-.
<Alt>->kitty <Ctrl>->tab/window/edit/jump <Space>->editor <Alt+Ctrl>->edit/completion
```

# Good resources

- https://neovimcraft.com/plugin/nanotee/nvim-lua-guide
- [Programming in Lua (first edition) online ver.](https://www.lua.org/pil/contents.html)

# Less common vim keymaps/tips

- Help
    - `:h v_i` to lookup what `i` does in visual mode. Or `c_<Up>` likewise
- Visual mode
    - E.g. `aw` in visual mode **extends** the selection, so can do `vawaW`, which extends selection from a word to a WORD
    - `o` in visual mode let you "change end"
    - `=` in visual mode let you re-indent the selected text
    - While in insert mode, use `C-o` to do a normal mode command
    - Caution: marks in visual mode are only set after leaving visual mode. `<cmd>` will execute a command without leaving visual mode while `:` leaves visual mode and enters command mode before processing the command.
- Command line mode
    - Use `<C-r>` to insert things like content of registers `<C-r>a`, current word under cursor w/ `<C-r><C-w>`, etc
    - Use `<C-\>e` to evaluate arbitrary vimscript expression and append the result to the command line. E.g. `expand("%")` to get the current filename. Other filename modifiers (`:h filename-modifiers`) include `%:p`, `%:p:t`, etc
    - Also see: ex mode
- Normal mode
    - `*` to highlight all occurrences of word under cursor, or current visual selection. And advance to the next occurrence. Useful to pair with `N` i.e. `*N`
    - `#` same as `*` but in opposite direction
    - (TODO)
- Ranges in command line mode
    - `60` targets line 60
    - `%` in cmdline is a shorthand for `1,$`, which targets the whole file
    - Interoperable with marks (see below)
    - `.` targets current line. Usually can be ignored e.g. `1` means `1,.`
    - Relative to target by e.g. `-1`, `+2`
    - `*` is same as `'<,'>` (see marks)
    - Append search term with `/e` to target the end rather the the beginning. E.g. `y/sometext/e`. See https://vimhelp.org/pattern.txt.html#search-offset
- Ex mode
    - `:h ex-commands` or `:h holy-grail`
    - `ex` is the predecessor of `vi`/`vim`. And commands such as 
    - ':s' for substitution. `:%s/<a>/<b>/gc` let you substitute in current buffer every occurence of `a` with `b` and ask for confirmation
        - `:&` repeat last `:s` (without its flags). Use `:&&` to repeat with all flags
        - Custom escape char / delimiter: e.g. `:s#a#b#gc`
        - When `<a>` is omitted e.g. `:s//<b>/g`, it auto uses the current selection (from `*` or search `/` `?`)
        - Capture gruop (?): `\0` refers to the whole search term. `\1` refers to the first capture group, ... E.g. `:%s/some\(.*\)/\1/g`. `()` has to be escaped
        - Also see `:sm` (subs with magic)
    - `:g` for line search/filter. An example of powerful combination is `:g/sometext/y A` which yanks every line that containers `sometext` into register `a`
    - `:m` for move
    - `:t` for duplicate/copy
    - `:i` for insert
    - `:d` for delete
    - `:r` for read the content of a file into current cursor pos
    - `:y` for yank
    - `:@` execute contents of register (i.e. macro; see below). `:@@` to repeat last `:@`
    - `:cdo` to execute command in each valid error list entry. See quickfix
    - `:cfdo` similar to above but for each file
    - `:chdir` to change dir
    - `:view` to open file as read-only
    - `:sort` to sort lines
    - `:recover` to recover a file from swap
    - `:messages` to see all messages (useful because old messages are overwritten by new ones)
- Diff
    - `:diffthis` to add current window to diff (must be in same tab) (shorthand for `:windo diffthis`)
    - `:diffsplit <file>` to diff another file in split. E.g. `:vert diffsplit <file>`
    - `:diffput` to put changes in current buffer into other one `current -> other`
    - `:diffget` to get changes from other buffer into current one `other -> current`
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
    - `:h g`
    - `gv` let you reselect last visual selection
    - `gi` let you enter insert mode in last insert position (where insert mode was last exited)
    - `gu`/`gU` are the uppercase/lowercase motion. E.g. `gUiw` will uppercase the entire word. `gUU` will uppercase the entire line
    - `gn`/`gN` are like `gv` but search forward/backward for the last search term (doesn't play well w/ flash unfortunately)
    - `gj`/`gk` to navigate between visual row (for wrapped lines)
- `z` for views and folds
    - `:h z`
    - `zz`/`zt`/`zb` for center/top/bottom cursor against screen
- Quickfix
    - `:h quickfix`
    - In format `File, row, col error message`
    - Use `:make` to add build errors to quickfix (list)
    - Use `:vimgrep <pattern> <path>` to add project-wide searches to quickfix. E.g. `:vim /sometext/ %`. `:vim` is short for `:vimgrep`
        - Supports glob pattern for `path`. E.g. `**/*.lua`
        - `f` to fuzzy. E.g. `:vim /text/f %`
    - `:set makeprg` such that can add build errors of other tools to quickfix. E.g. `:set makeprg=pytest` and `:make`
    - `:cn` or `:cp` to navigate between quickfix. `:copen` to open quickfix window
- `[]`
    - (TODO)
    - `{` and `}` to navigate between blank lines
- Text objects (built-in)
    - (TODO)
- Command line window
    - (TODO)
- Keymapping
    - `noremap` flag: don't remap to other user-defined keymap
    - `expr` flag: `<expr>` is eavluated when the key combination is invoked, such that the command (`rhs`) can be dynamic

# Plugin Development

- `:so <file>` to source the lua file (just like zsh)
- Launch neovim as `v --cmd "set rtp+=<path-to-lua-lib>"` to add plugin locally
- Packages/plugins are cached when neovim first loads them. With the snippet below, we can have a quick feedback loop `:Test` -> `:so %` -> `:Test` -> ...
- Borrow AST information from Treesitter playground! (vscode doesn't support this). https://github.com/nvim-treesitter/playground . Debug using `:InspectTree` and `:EditQuery` (requires nightly 0.10+).
- `vim.pretty_print` for pretty print

```lua
vim.api.create_user_command("Test", function()
  package.loaded.PackageName = nil  -- clear cache
  require("PackageName").my_func()
end, {})
```

# TODO

**High priority**

- LSP rename workflow (WorkspaceEdit[]). Perhaps have a watchman daemon running and a local socket server that takes a list of subscribers?
- Fzf grep (fzf disabled) focus entry not updating when query changed
- Fzf "watch mode" that runs the command in the background and hashes it to see if it output changes? Require idempotent command
- LF image preview over SSH
- SSH line editor ignore delay?
- Syncthing clipboard
- Karabiner [command + left/right]
- Fzf TODO comments
- Fzf backups
- Tests
- LSP import path update (with watchman and LSP willrename etc...)
- Project specific config w/ exrc https://github.com/klen/nvim-config-local
- Custom treesitter textobjects plugin
- Fzf one after another doesn't enter insert mode
- Remove all usage of global var
- Output bat stuff into scratch buffer for easy copy
- Backup filename collision + auto cleanup
- Lf show git status (pico-lf?)
- Lf flatten dir (for Java)
- Markdown syntax highlighting
- Fzf Pulumi
- Fzf brew services and formulae?
- Fzf terraform
- Fzf k8s

**Low priority**

- Performance profiling & optimization (w/ flamegraph)
- Fix Fzf somethings hang if actions happen too quick?
- Fzf core - handler error reporting and handling (at the moment is sliented)
- LF preview in nvim
- Custom autopair and comment plugin
- Git worktree workflow
- Custom copilot plugin (possible to use chat?)
- Lf create_new multi-layer dir support
- Tabline dedup by git-files
- React dev workflow
