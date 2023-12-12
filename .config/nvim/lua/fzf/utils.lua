local M = {}

local utils = require("utils")
local config = require("fzf.config")

M.git_toplevel = [[git -C "$(git rev-parse --show-toplevel)"]]

M.git_files = function(git_dir)
  return string.format(
    [[{ echo "$(git -C %s ls-files --full-name --exclude-standard)"; echo "$(git -C %s ls-files --full-name --others --exclude-standard)"; }]],
    git_dir,
    git_dir
  )
end

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

M.get_filepath_from_git_root = function(filepath, opts)
  opts = vim.tbl_extend("force", {
    git_root = M.get_git_toplevel(),
    include_git_root = false,
  }, opts or {})

  -- Make filepath relative to the full path (relative to ~) to git root
  local path = vim.fn.fnamemodify(filepath, ":~" .. opts.git_root .. ":.")
  if not opts.include_git_root then path = path:gsub("[^/]+/", "", 1) end
  return path
end

M.convert_git_filepath_to_fullpath = function(filepath, git_dir)
  return git_dir .. "/" .. filepath
end

return M
