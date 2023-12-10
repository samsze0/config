local M = {}

local utils = require("m.utils")
local config = require("m.fzf.config")

M.git_toplevel = [[git -C "$(git rev-parse --show-toplevel)"]]

M.git_files = string.format(
  [[{ echo "$(%s ls-files --full-name --exclude-standard)"; echo "$(%s ls-files --full-name --others --exclude-standard)"; }]],
  M.git_toplevel,
  M.git_toplevel
)

M.git_files_cwd = string.format(
  [[{ echo "$(git ls-files --full-name --exclude-standard)"; echo "$(git ls-files --full-name --others --exclude-standard)"; }]]
)

-- Trick git into thinking it's running in a tty
-- https://github.com/dandavison/delta/discussions/840
M.like_tty = [[script -q /dev/null]]

M.get_git_toplevel = function()
  return vim.trim(vim.fn.system([[git rev-parse --show-toplevel]]))
end

M.edit_selected_files = function(edit_cmd, selection)
  -- Filter invalid selection entries and open them
  selection = utils.filter(selection, function(v) return vim.trim(v) ~= "" end)
  if #selection > 0 then
    if config.debug then vim.notify("Fzf: opening selections") end
    for _, file in ipairs(selection) do
      vim.cmd(string.format([[%s %s]], edit_cmd, file))
    end
  end
end

return M
