local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

-- TODO: remove delete files and git submodules from entries
-- TODO: make this async because it doesn't need initial pos

-- Fzf all git files in the given git directory.
-- If git_dir is nil, then fzf all files in the current directory.
--
---@param opts? { git_dir?: string, fd_extra_args?: string, max_num_files?: number }
M.files = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    fd_extra_args = "--hidden --follow --exclude .git",
    max_num_files = 1000,
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
  if #entries > opts.max_num_files then
    vim.error("Too many git files")
    return
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
          vim.error("Failed to determine if file is binary using file command")
          set_preview_content({
            "Cannot determine if file is binary",
          })
          return
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
      ["--preview-window"] = helpers.fzf_default_preview_window_args,
    }),
  })
end

return M
