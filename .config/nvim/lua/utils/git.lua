local M = {}

---@param git_dir string
---@param opts? { as_cmd?: boolean, filter_directories?: boolean }
---@return string | string[] cmd_or_git_files
M.git_files = function(git_dir, opts)
  if vim.fn.executable("git") ~= 1 then error("git is not installed") end

  opts = vim.tbl_extend("force", {
    as_cmd = false,
    filter_directories = false, -- Used to remove symlinks. Can hinder performance
  }, opts or {})

  -- GIT_TEMP=$(mktemp); git submodule --quiet foreach 'echo $path' > $GIT_TEMP; git ls-files --full-name --no-recurse-submodules --exclude-standard --exclude-from $GIT_TEMP

  local cmd = string.format(
    [[{ echo "$(git -C %s ls-files --full-name --exclude-standard)"; echo "$(git -C %s ls-files --full-name --others --exclude-standard)"; }]],
    git_dir,
    git_dir
  )
  if opts.filter_directories then
    -- TODO: Possibly another way that doesn't involve xargs?
    -- Or remove the need to filter_directories if rg can filter out directories?
    -- Or if git can filter out symbolic links?
    cmd = cmd .. " | xargs -I {} bash -c 'if [[ ! -d {} ]]; then echo {}; fi'"
  end
  if opts.return_as_cmd then return cmd end

  local results = vim.fn.systemlist(cmd, nil, false)
  if vim.v.shell_error ~= 0 then error("Failed to get git files") end
  return results
end

---@param opts? { as_cmd?: boolean }
---@return string? cmd_or_git_dir
M.current_git_dir = function(opts)
  if vim.fn.executable("git") ~= 1 then error("git is not installed") end

  opts = vim.tbl_extend("force", {
    as_cmd = false,
  }, opts or {})

  local cmd = [[git rev-parse --show-toplevel]]
  if opts.as_cmd then return cmd end

  local path = vim.trim(vim.fn.system(cmd))
  if vim.v.shell_error ~= 0 then return nil end
  return path
end

---@param filepath string
---@param opts? { git_dir?: string, include_git_dir?: boolean }
---@return string gitpath
M.convert_filepath_to_gitpath = function(filepath, opts)
  if vim.fn.executable("git") ~= 1 then error("git is not installed") end

  opts = vim.tbl_extend("force", {
    git_dir = M.current_git_dir(),
  }, opts or {})

  filepath = vim.fn.fnamemodify(filepath, ":p")
  local git_dir = vim.fn.fnamemodify(opts.git_dir, ":p")

  if filepath:sub(1, #git_dir) ~= git_dir then
    error("The filepath is not inside the git directory")
  end

  local path = vim.fn.fnamemodify(filepath, ":~" .. git_dir .. ":.")
  path = path:match("/(.*)")
  if not path then -- If filepath happens to be the git_dir
    path = ""
  end
  return path
end

return M
