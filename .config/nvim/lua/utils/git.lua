local utils = require("utils")

local M = {}

-- TODO: support filtering out unreadable files in shell script

-- Return the shell command for retrieving the list of Git-aware files
--
---@param git_dir string
---@return string cmd
M.files_cmd = function(git_dir)
  -- if opts.filter_unreadable then
  --   xargs is too slow
  --   cmd = cmd .. " | xargs -I {} bash -c 'if [[ ! -d {} ]]; then echo {}; fi'"
  --   Can git can filter out symbolic links?
  -- end

  -- TODO: filter out git submodules
  -- GIT_TEMP=$(mktemp); git submodule --quiet foreach 'echo $path' > $GIT_TEMP; git ls-files --full-name --no-recurse-submodules --exclude-standard --exclude-from $GIT_TEMP

  return ([[{ echo "$(git -C %s ls-files --full-name --exclude-standard)"; echo "$(git -C %s ls-files --full-name --others --exclude-standard)"; }]]):format(
    git_dir,
    git_dir
  )
end

-- Return the list of Git-aware files
--
---@alias GitUtilsFilesOptions { filter_unreadable?: boolean }
---@param git_dir string
---@param opts? GitUtilsFilesOptions
---@return string[]
M.files = function(git_dir, opts)
  if vim.fn.executable("git") ~= 1 then error("git is not installed") end

  opts = utils.opts_extend({
    filter_unreadable = false, -- Whether or not remove unreadable files
  }, opts)
  ---@cast opts GitUtilsFilesOptions

  local files = utils.systemlist(M.files_cmd(git_dir), {
    keepempty = false,
  })
  ---@cast files string[]

  if opts.filter_unreadable then
    files = utils.filter(
      files,
      function(i, e) return vim.fn.filereadable(git_dir .. "/" .. e) == 1 end
    )
  end

  -- Filter out empty lines
  return utils.filter(files, function(i, e) return vim.trim(e):len() > 0 end)
end

-- Return the shell command for retrieving current git directory
M.current_dir_cmd = function() return [[git rev-parse --show-toplevel]] end

---@param opts? { }
---@return string? git_dir
M.current_dir = function(opts)
  if vim.fn.executable("git") ~= 1 then error("git is not installed") end

  opts = utils.opts_extend({}, opts)

  local path = vim.trim(vim.fn.system(M.current_dir_cmd()))
  if vim.v.shell_error ~= 0 then return nil end
  return path
end

---@param filepath string
---@param opts? { git_dir?: string, include_git_dir?: boolean }
---@return string gitpath
M.convert_filepath_to_gitpath = function(filepath, opts)
  if vim.fn.executable("git") ~= 1 then error("git is not installed") end

  opts = vim.tbl_extend("force", {
    git_dir = M.current_dir(),
  }, opts or {})

  filepath = vim.fn.fnamemodify(filepath, ":p")
  local git_dir = vim.fn.fnamemodify(opts.git_dir, ":p")

  if filepath:sub(1, #git_dir) ~= git_dir then
    error(
      ("The filepath %s is not inside the git directory %s"):format(
        filepath,
        git_dir
      )
    )
  end

  local path = vim.fn.fnamemodify(filepath, ":~" .. git_dir .. ":.")
  path = path:match("/(.*)")
  if not path then -- If filepath happens to be the git_dir
    path = ""
  end
  return path
end

return M
