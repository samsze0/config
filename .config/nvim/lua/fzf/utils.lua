local M = {}

local utils = require("utils")
local config = require("fzf.config")

M.git_files = function(git_dir)
  return string.format(
    [[{ echo "$(git -C %s ls-files --full-name --exclude-standard)"; echo "$(git -C %s ls-files --full-name --others --exclude-standard)"; }]],
    git_dir,
    git_dir
  )
end

-- Trick git into thinking it's running in a tty
-- https://github.com/dandavison/delta/discussions/840
M.like_tty = [[script -q /dev/null]]

M.get_git_toplevel = function()
  return vim.trim(vim.fn.system([[git rev-parse --show-toplevel]]))
end

M.convert_filepath_to_gitpath = function(filepath, opts)
  opts = vim.tbl_extend("force", {
    git_root = M.get_git_toplevel(),
    include_git_root = false,
  }, opts or {})

  -- Make filepath relative to the full path (relative to ~) to git root
  local path = vim.fn.fnamemodify(filepath, ":~" .. opts.git_root .. ":.")
  if not opts.include_git_root then path = path:gsub("[^/]+/", "", 1) end
  return path
end

M.convert_gitpath_to_relpath = function(filepath, git_dir)
  return git_dir .. "/" .. filepath
end

M.fzf_initial_preview_scroll_offset = function(offset, opts)
  opts = vim.tbl_extend("force", {
    fixed_header = 0,
    center = true,
  }, opts or {})
  return string.format(
    [[~%s,+%s%s,+%s%s]],
    tostring(opts.fixed_header),
    tostring(opts.fixed_header),
    opts.center and "/2" or "",
    tostring(offset),
    opts.center and "/2" or ""
  )
end

M.generate_fzf_reload_action = function(input)
  return string.format(
    "reload(%s)",
    string.format(
      [[cat <<EOF
%s
EOF]],
      table.concat(input, "\n")
    )
  )
end

M.fzf_heredoc_shellescape = function(str)
  str = string.gsub(str, [[\n]], [[ ]])
  str = string.gsub(str, [["]], [[“]])
  str = string.gsub(str, [[']], [[“]])
  return string.gsub(str, "EOF", "eof")
end

return M
