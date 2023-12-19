local M = {}

FZF_TMPFILE = vim.fn.tempname()
local utils = require("utils")

M.git_files = function(git_dir, opts)
  git_dir = git_dir or M.git_root_dir()

  opts = vim.tbl_extend("force", {
    return_as_cmd = false,
    convert_gitpaths_to_relpaths = false,
  }, opts or {})
  local cmd = string.format(
    [[{ echo "$(git -C %s ls-files --full-name --exclude-standard)"; echo "$(git -C %s ls-files --full-name --others --exclude-standard)"; }]],
    git_dir,
    git_dir
  )
  if opts.return_as_cmd then
    return cmd
  else
    local entries = vim.fn.systemlist(cmd, nil, false)
    if not opts.convert_gitpaths_to_relpaths then return entries end
    return utils.map(
      entries,
      function(_, e)
        return M.convert_gitpath_to_filepath(
          e,
          { git_dir = git_dir, relpath = true }
        )
      end
    )
  end
end

M.git_root_dir = function(opts)
  opts = vim.tbl_extend("force", {
    return_as_cmd = false,
  }, opts or {})

  local cmd = [[git rev-parse --show-toplevel]]

  return opts.return_as_cmd and cmd or vim.trim(vim.fn.system(cmd))
end

M.convert_filepath_to_gitpath = function(filepath, opts)
  opts = vim.tbl_extend("force", {
    git_dir = M.git_root_dir(),
    include_git_dir = false,
  }, opts or {})

  -- Make filepath relative to the full path (relative to ~) to git root
  local path = vim.fn.fnamemodify(filepath, ":~" .. opts.git_dir .. ":.")
  if not opts.include_git_dir then path = path:gsub("[^/]+/", "", 1) end
  return path
end

M.convert_gitpath_to_filepath = function(filepath, opts)
  opts = vim.tbl_extend("force", {
    git_dir = M.git_root_dir(),
    relpath = true,
  }, opts or {})

  local fullpath = opts.git_dir .. "/" .. filepath
  if opts.relpath then
    return vim.fn.fnamemodify(fullpath, ":~:.")
  else
    return fullpath
  end
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

M.write_to_tmpfile = function(content)
  vim.fn.writefile(
    type(content) == "string" and vim.split(content, "\n") or content,
    FZF_TMPFILE
  )
  return FZF_TMPFILE
end

return M
