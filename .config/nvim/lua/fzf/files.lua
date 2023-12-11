local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")

-- TODO: no-git mode
M.files = function()
  local entries = vim.fn.systemlist(fzf_utils.git_files, nil, false)

  utils.sort_filepaths(entries, function(e) return e end)

  core.fzf(
    table.concat(entries, "\n"),
    function(selection)
      vim.cmd(string.format([[e %s]], fzf_utils.convert_git_root_filepath_to_fullpath(selection[1])))
    end,
    {
      fzf_preview_cmd = string.format(
        "bat %s %s/{}",
        config.bat_default_opts,
        fzf_utils.get_git_toplevel()
      ),
      fzf_prompt = "Files",
      fzf_on_focus = function(selection) end,
      fzf_binds = {
        ["ctrl-y"] = function()
          local current_selection = FZF_CURRENT_SELECTION
          vim.fn.setreg("+", fzf_utils.convert_git_root_filepath_to_fullpath(current_selection))
        end,
        ["ctrl-w"] = function()
          local current_selection = FZF_CURRENT_SELECTION
          vim.cmd(string.format([[vsplit %s]], fzf_utils.convert_git_root_filepath_to_fullpath(current_selection)))
        end,
        ["ctrl-t"] = function ()
          local current_selection = FZF_CURRENT_SELECTION
          vim.cmd(string.format([[tabnew %s]], fzf_utils.convert_git_root_filepath_to_fullpath(current_selection)))
        end
      },
    }
  )
end

return M
