# Neovim FZF plugin

An unopinionated thin-wrapper around fzf. Basic knowledge of fzf is required to use this plugin.

## Usage

This plugin by default comes with many built-in "selectors" (e.g. `files`, `buffers`, `grep`, `docker containers`, `git status`, etc.), however, the true power of this plugin lies in its ability to create custom tailored selectors with ease.

Here is how you would invoke the built-in `files` selector:

```lua
require('fzf.files').files()

-- Or you can bind it to a keymap
vim.keymap.set('n', '<leader>ff', require('fzf.files').files, {})
```

Here is how you would build a custom selector:

```lua
local fzf_core = require('fzf.core')
local fzf_utils = require('fzf.utils')
local fzf_helpers = require('fzf.helpers')

local entries = {
  fzf_utils.join_by_delim("apple", "red"),
  fzf_utils.join_by_delim("banana", "yellow"),
  fzf_utils.join_by_delim("grapes", "purple"),
}

fzf_core.fzf(entries, {
  prompt = "Fruits",
  preview_cmd = "echo {1}",
  binds = {
    ["+select"] = function(state)
      vim.info(state.focused_entry)
    end,
  },
  extra_args = {
    ["--with-nth"] = "1..",
    ["--preview-window"] = "right,50%,border-none,wrap,nofollow,nocycle",
  }
})
```

Here is the implementation of the built-in `files` selector:

```lua
local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

-- Fzf all git files in the given git directory.
-- If git_dir is nil, then fzf all files in the current directory.
--
---@param opts? { git_dir?: string, fd_extra_args?: string }
M.files = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    fd_extra_args = "--hidden --follow --exclude .git",
  }, opts or {})

  local parse_entry = function(entry)
    if opts.git_dir then
      return vim.fn.fnamemodify(opts.git_dir .. "/" .. entry, ":.")
    else
      return entry
    end
  end

  local entries
  if opts.git_dir then
    entries = git_utils.git_files(opts.git_dir)
  else
    if vim.fn.executable("fd") ~= 1 then error("fd is not installed") end
    entries = vim.fn.systemlist(
      string.format([[fd --type f --no-ignore %s]], opts.fd_extra_args)
    )
  end
  ---@cast entries string[]
  entries = utils.sort_by_files(entries)

  local win = vim.api.nvim_get_current_win()

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout()

  core.fzf(entries, {
    prompt = "Files",
    layout = layout,
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
        })
      end,
      ["focus"] = function(state)
        local entry = state.focused_entry
        local path = parse_entry(entry)

        local is_binary =
          vim.fn.system("file --mime " .. path):match("charset=binary")

        if vim.v.shell_error ~= 0 then
          error("Failed to determine if file is binary using file command")
        end

        if is_binary then
          set_preview_content({ "No preview available" })
          return
        end

        local filename = vim.fn.fnamemodify(path, ":t")
        local ft = vim.filetype.match({
          filename = filename,
          contents = vim.fn.readfile(path),
        })

        set_preview_content(vim.fn.readfile(path))
        if ft then vim.bo[popups.nvim_preview.bufnr].filetype = ft end

        -- Switch to preview window and back in order to refresh scrollbar
        -- TODO: Remove this once scrollbar plugin support remote refresh
        vim.api.nvim_set_current_win(popups.nvim_preview.winid)
        vim.api.nvim_set_current_win(popups.main.winid)
      end,
      ["ctrl-y"] = function(state)
        local entry = state.focused_entry
        local path = parse_entry(entry)

        vim.fn.setreg("+", path)
        vim.notify(string.format([[Copied %s to clipboard]], path))
      end,
      ["ctrl-w"] = function(state)
        local entry = state.focused_entry
        local path = parse_entry(entry)

        core.abort_and_execute(
          function() vim.cmd(string.format([[vsplit %s]], path)) end
        )
      end,
      ["ctrl-t"] = function(state)
        local entry = state.focused_entry
        local path = parse_entry(entry)

        core.abort_and_execute(
          function() vim.cmd(string.format([[tabnew %s]], path)) end
        )
      end,
      ["+select"] = function(state)
        local entry = state.focused_entry
        local path = parse_entry(entry)

        jumplist.save(win)
        vim.cmd(string.format([[e %s]], path))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end
```

## IPC w/ Fzf

By default, Fzf itself listens for HTTP requests on some port. This makes it convenient to execute Fzf actions from remote. However, to achieve bi-directional communication w/ Fzf, we would also need to setup a server to which Fzf can send messages to.

On init, this plugin would create an unix socket server. The core of this plugin is to abstract away the low-level message exchanging process between the two servers.

Common flows:

1. `Fzf event --triggers--> fzf action`: In this flow, no communication would take place between the two servers as everything would take place internally in fzf.
2. `Fzf event --triggers--> lua callback`: In this flow, the fzf server would write a message to our server whenever the event triggers which in turn triggers the callback.
3. `lua --request--> fzf server`: In this flow, our server would send a request to fzf and not wait for its response.
4. `lua --request--> fzf server --response--> lua`: In this flow, our server would send a request to fzf and wait for its response.

You may specify lua functions or fzf actions as fzf event handlers (or a combination or both). 

Here is how you would carry out the above flows:

```lua
local fzf_core = require('fzf.core')
local fzf_utils = require('fzf.utils')

fzf_core.fzf(entries, {
  -- ...
  binds = {
    -- 1. fzf event -> fzf action
    focus = "execute-silence(echo \"hi!\")",
    -- 2. fzf event -> fzf action
    ["ctrl-y"] = function()
      vim.notify("hi!")

      -- 3. lua -> fzf server
      fzf_core.send_to_fzf("pos(1)")

      -- 4. lua -> fzf server -> lua
      fzf_core.request_fzf("{+}", function(response)
        local current_selections = parse_response(response)
        -- ...
      end)
    end,
  },
  -- ...
})
```

## Special events

Aside from the events that fzf provides (e.g. ""), this plugin also provides these extra events:

- `+select`: triggered when the user selects an entry (i.e. pressing `enter`)
- `+abort`: triggered when the user aborts the fzf process
- `+after-exit`: triggered when the fzf process exits. This event is triggered after `+abort` and `+select`.
- `+before-start`: triggered before the fzf process starts

These extra events are triggered on the lua side and can only accept lua functions as handlers.

## Built-in event handlers

A number of event handlers are built-in to this plugin. They are injected to the `opts.binds` table when you invoke `fzf.core.fzf`. They are responsible for updating variable fields of the `state` object (see below).

## State

Fzf events callbacks (lua) are passed a `state` object which contains the following fields:

- `port`: the port on which the fzf server is listening on
- `query`: the current query
- `focused_entry`: the currently focused entry
- `focused_entry_index`: the index of the currently focused entry (1-indexed)
- `popups`: the Nui popup windows that forms the UI

Extra events are prefixed with `+`.

`state` is also the only argument that the callbacks would receive. If you want to get the selected entry from the `+select` event, you should use `state.focused_entry` or `state.focused_entry_index`. If there are multiple selected entries, you should use the `fzf.core.get_current_selections` helper function.

## Fzf command line args

The following command line args should not be included in `extra_args` as they are already handled by this plugin:

- `--listen`
- `--ansi`
- `--async`
- `--propmt`
- `--border`
- `--height`
- `--bind`
- `--delimiter`

## Preview options

The following 3 preview options come built-in with this plugin:

- Fzf preview: preview by using fzf's built-in preview window.
- Nvim preview: preview by dumping content to a neovim window.
- Nvim preview (terminal mode): preview by dumping content to a neovim window, and then setting the preview buffer's filetype to `terminal`. This plugin will process the ANSI escape sequences and mimic the way the preview content is presented in the terminal.

## Built-in selectors

The following selectors come built-in with this plugin:

General:

- `files`
- `buffers`
- `tabs`
- `grep` (workspace / single-buffer)
- `loclist`
- `backups`
- `jumplist` (for the custom jumplist implementation that comes with this plugin)
- `notifications` (for the custom `vim.notify` backend that comes with this plugin)
- `undo tree`
- `todo comments` (TODO)

Git:

- `git status`
- `git commits` (git log)
- `git branches`
- `git reflog`
- `git stash`
- `git submodules`

Diagnostics:

- `diagnostics` (workspace / single-buffer)

Lsp:

- `lsp references`
- `lsp definitions`
- `lsp document symbols`
- `lsp workspace symbols`
- `lsp type definitions` (TODO)
- `lsp implementations` (TODO)
- `lsp code actions` (TODO)
- `lsp declarations` (TODO)

Docker:

- `docker containers`
- `docker images`

Kubernetes:

- `k8s pods`

Terraform:

(TODO)

Pulumi:

(TODO)

## Workspace edits

Workspace edits are edits that are applied to multiple files across the current workspace. Examples of workspace edits are `rename` and `find-and-replace`. This plugin provides a way to perform workspace edits by leveraging Vim's quickfix list.

## Multi-stage selector

(TODO)

## License

MIT
