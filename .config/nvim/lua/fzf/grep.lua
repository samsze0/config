local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")

-- TODO: no-git mode
M.grep = function()
  local function get_entries(query)
    if query == "" then return {} end

    local git_files = vim.fn.systemlist(fzf_utils.git_files, nil, false)
    utils.sort_filepaths(git_files, function(e) return e end)

    if false then
      local entries = {}
      for f in ipairs(git_files) do
        utils.list_join(
          entries,
          utils.map(
            vim.fn.systemlist(
              string.format(
                [[rg %s "%s" %s]],
                config.rg_default_opts,
                query,
                fzf_utils.convert_git_filepath_to_fullpath(f)
              )
            ),
            function(e) return string.format("%s%s%s", f, utils.nbsp, e) end
          )
        )
      end
      return entries
    else
      local entries = vim.split(
        vim.fn.system(
          string.format(
            "rg %s %s %s",
            config.rg_default_opts,
            query,
            table.concat(git_files, " ")
          )
        ),
        "\n"
      )
      return entries
    end
  end

  core.fzf("", function(selection)
    local filepath = vim.split(selection[1], utils.nbsp)[1]
    vim.cmd(
      string.format(
        [[e %s]],
        fzf_utils.convert_git_filepath_to_fullpath(filepath)
      )
    )
  end, {
    fzf_preview_cmd = string.format(
      "bat %s %s/{}",
      config.bat_default_opts,
      fzf_utils.get_git_toplevel()
    ),
    fzf_prompt = "Grep",
    fzf_on_focus = function(selection) end,
    fzf_on_prompt_change = function(query)
      core.send_to_fzf(string.format(
        "reload(%s)",
        string.format(
          [[cat <<EOF
%s
EOF]],
          table.concat(get_entries(query), "\n")
        )
      ))
    end,
    fzf_binds = {
      ["ctrl-y"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local filepath = vim.split(current_selection, utils.nbsp)[1]
        vim.fn.setreg(
          "+",
          fzf_utils.convert_git_filepath_to_fullpath(filepath)
        )
      end,
      ["ctrl-w"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local filepath = vim.split(current_selection, utils.nbsp)[1]
        vim.cmd(
          string.format(
            [[vsplit %s]],
            fzf_utils.convert_git_filepath_to_fullpath(filepath)
          )
        )
      end,
      ["ctrl-t"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local filepath = vim.split(current_selection, utils.nbsp)[1]
        vim.cmd(
          string.format(
            [[tabnew %s]],
            fzf_utils.convert_git_filepath_to_fullpath(filepath)
          )
        )
      end,
    },
  })
end

return M
