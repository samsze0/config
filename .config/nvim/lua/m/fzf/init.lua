local M = {}

local core = require("m.fzf.core")
local config = require("m.fzf.config")
local utils = require("m.fzf.utils")

M.setup = function(opts) end

M.git_files = function()
  local entries = vim.fn.system(
    string.format(
      [[{ echo "$(%s ls-files --full-name --exclude-standard)"; echo "$(%s ls-files --full-name --others --exclude-standard)"; }]],
      utils.git_toplevel,
      utils.git_toplevel
    )
  )
  entries = entries:gsub("\n$", "") -- Remove the extra newline at the end
  core.fzf(
    entries,
    function(selection) vim.notify(table.concat(selection, " ")) end,
    {
      fzf_preview_cmd = string.format(
        "bat %s %s/{}",
        config.bat_default_opts,
        utils.get_git_toplevel()
      ),
    }
  )
end

return M
