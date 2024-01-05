local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

local git_submodules = function(on_submodule)
  local submodules =
    vim.fn.systemlist([[git submodule --quiet foreach 'echo $path']])
  if vim.v.shell_error ~= 0 then
    vim.notify("Error running git submodule command", vim.log.levels.ERROR)
    return
  end
  submodules = utils.map(submodules, function(_, e) return vim.trim(e) end)

  local git_dir = git_utils.current_git_dir()

  local function get_relpath_from_selection()
    local selection = FZF.current_selection

    local submodule_path = selection
    submodule_path = git_dir .. "/" .. submodule_path

    return submodule_path
  end

  core.fzf(submodules, {
    fzf_on_select = function()
      local submodule_path = get_relpath_from_selection()
      on_submodule(submodule_path)
    end,
    fzf_preview_cmd = nil,
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
    fzf_prompt = "Git-Submodules",
    fzf_binds = {
      ["ctrl-y"] = function()
        local submodule_path = get_relpath_from_selection()

        vim.fn.setreg("+", submodule_path)
        vim.notify(string.format([[Copied to clipboard: %s]], submodule_path))
      end,
    },
  })
end

return git_submodules
