local M = {}

local core = require("m.fzf.core")
local config = require("m.fzf.config")
local fzf_utils = require("m.fzf.utils")
local utils = require("m.utils")

M.git_files = function()
  local entries = vim.fn.system(fzf_utils.git_files)
  entries = entries:gsub("\n$", "") -- Remove the extra newline at the end
  core.fzf(
    entries,
    function(selection) vim.notify(table.concat(selection, " ")) end,
    {
      fzf_preview_cmd = string.format(
        "bat %s %s/{}",
        config.bat_default_opts,
        fzf_utils.get_git_toplevel()
      ),
      fzf_prompt = "GitFiles",
      fzf_on_focus = function(selection)
      end,
    }
  )
end

return M
