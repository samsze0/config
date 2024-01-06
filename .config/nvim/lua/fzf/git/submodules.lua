local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")

-- Fzf all git submodules
--
---@param on_submodule function
local git_submodules = function(on_submodule)
  local submodules =
    vim.fn.systemlist([[git submodule --quiet foreach 'echo $path']])

  if vim.v.shell_error ~= 0 then
    vim.error("Error fetching git submodules")
    return
  end

  submodules = utils.map(submodules, function(_, e) return vim.trim(e) end)

  local git_dir = git_utils.current_git_dir()

  local function parse_entry(entry)
    local submodule_path = entry
    submodule_path = git_dir .. "/" .. submodule_path

    return submodule_path
  end

  core.fzf(submodules, {
    prompt = "Git-Submodules",
    binds = {
      ["+select"] = function(state)
        local submodule_path = parse_entry(state.focused_entry)
        on_submodule(submodule_path)
      end,
      ["ctrl-y"] = function(state)
        local submodule_path = parse_entry(state.focused_entry)

        vim.fn.setreg("+", submodule_path)
        vim.info(string.format([[Copied to clipboard: %s]], submodule_path))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
      ["--preview-window"] = helpers.fzf_default_preview_window_args,
    }),
  })
end

return git_submodules
