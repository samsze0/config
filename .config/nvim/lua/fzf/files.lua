local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local layouts = require("fzf.layouts")
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

  local files

  local get_filepath = function(index)
    local file = files[index]
    if opts.git_dir then
      return vim.fn.fnamemodify(opts.git_dir .. "/" .. file, ":.")
    else
      return file
    end
  end

  if opts.git_dir then
    files = git_utils.git_files(opts.git_dir)
  else
    if vim.fn.executable("fd") ~= 1 then error("fd is not installed") end
    files = utils.systemlist(
      string.format([[fd --type f --no-ignore %s]], opts.fd_extra_args)
    )
  end

  if #files > opts.max_num_files then error("Too many git files") end
  ---@cast files string[]

  files = utils.sort_by_files(files)

  local fzf_rows = utils.map(files, function(i, e) return e end) -- Shallow clone

  local current_win = vim.api.nvim_get_current_win()

  local layout, popups, set_preview_content, binds =
    layouts.create_nvim_preview_layout()

  core.fzf(fzf_rows, {
    prompt = "Files",
    layout = layout,
    main_popup = popups.main,
    binds = fzf_utils.bind_extend(binds, {
      ["+before-start"] = function(state)
        popups.main.border:set_text(
          "bottom",
          " <select> goto | <w> goto (window) | <t> goto (tab) | <y> copy path "
        )
      end,
      ["focus"] = function(state)
        local path = get_filepath(state.focused_entry_index)

        popups.nvim_preview.border:set_text("top", " " .. path .. " ")

        if vim.fn.filereadable(vim.fn.fnamemodify(path, ":p")) ~= 1 then
          set_preview_content({ "File not readable, or doesnt exist" })
          return
        end

        local is_binary = utils
          .system("file --mime " .. path, {
            on_error = function()
              set_preview_content({
                "Cannot determine if file is binary",
              })
            end,
          })
          :match("charset=binary")

        if is_binary then
          set_preview_content({ "No preview available" })
          return
        end

        helpers.preview_file(path, popups.nvim_preview)
      end,
      ["ctrl-y"] = function(state)
        local path = get_filepath(state.focused_entry_index)

        vim.fn.setreg("+", path)
        vim.info(string.format([[Copied %s to clipboard]], path))
      end,
      ["ctrl-w"] = function(state)
        local path = get_filepath(state.focused_entry_index)

        core.abort_and_execute(
          state.id,
          function() vim.cmd(string.format([[vsplit %s]], path)) end
        )
      end,
      ["ctrl-t"] = function(state)
        local path = get_filepath(state.focused_entry_index)

        core.abort_and_execute(
          state.id,
          function() vim.cmd(string.format([[tabnew %s]], path)) end
        )
      end,
      ["+select"] = function(state)
        local path = get_filepath(state.focused_entry_index)

        jumplist.save(current_win)
        vim.cmd(string.format([[e %s]], path))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end

return M
