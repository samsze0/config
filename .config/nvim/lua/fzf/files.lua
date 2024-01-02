local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

-- Fzf all git files in the given git directory.
-- If no git_dir is given, then fzf all files in the current directory.
--
---@param opts? { git_dir?: string, fd_extra_args?: string }
M.files = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    fd_extra_args = "--hidden --follow --exclude .git",
  }, opts or {})

  local get_selection = function()
    local selection = FZF.current_selection

    if opts.git_dir then
      return vim.fn.fnamemodify(opts.git_dir .. "/" .. selection, ":.")
    else
      return selection
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

  local win = vim.api.nvim_get_current_win()

  entries = utils.sort_by_files(entries)

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout()

  core.fzf(entries, {
    layout = layout,
    fzf_preview_cmd = nil,
    fzf_prompt = "Files",
    fzf_on_select = function()
      local filepath = get_selection()
      jumplist.save(win)
      vim.cmd(string.format([[e %s]], filepath))
    end,
    before_fzf = function()
      helpers.set_keymaps_for_nvim_preview(popups.main, popups.nvim_preview)
      helpers.set_keymaps_for_popups_nav({
        { popup = popups.main, key = "<C-s>", is_terminal = true },
        { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
      })
    end,
    fzf_on_focus = function()
      local path = get_selection()

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
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local path = get_selection()
        vim.fn.setreg("+", path)
        vim.notify(string.format([[Copied %s to clipboard]], path))
      end,
      ["ctrl-w"] = function()
        local path = get_selection()
        core.abort_and_execute(
          function() vim.cmd(string.format([[vsplit %s]], path)) end
        )
      end,
      ["ctrl-t"] = function()
        local path = get_selection()
        core.abort_and_execute(
          function() vim.cmd(string.format([[tabnew %s]], path)) end
        )
      end,
    }),
    nvim_preview = true,
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
  })
end

return M
