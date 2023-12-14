local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local uv = vim.loop
local uv_utils = require("utils.uv")

-- TODO: no-git mode
M.grep = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = fzf_utils.get_git_toplevel(),
  }, opts or {})

  local function get_filepath_from_selection(selection)
    selection = selection or FZF_STATE.current_selection

    return vim.split(selection, utils.nbsp)[1]
  end

  core.fzf({}, function(selection)
    local filepath = vim.split(selection[1], utils.nbsp)[1]
    vim.cmd(
      string.format([[e %s]], fzf_utils.convert_gitpath_to_relpath(filepath))
    )
  end, {
    -- fzf_async = true,
    fzf_preview_cmd = string.format(
      "bat %s --highlight-line {2} %s/{1}",
      helpers.bat_default_opts,
      opts.git_dir
    ),
    fzf_prompt = "Grep",
    fzf_on_focus = function() end,

    fzf_on_prompt_change = function(query)
      -- Important: most work should be carried out by the preview function
      core.send_to_fzf(
        "reload@"
          .. string.format(
            [[rg %s "%s" $(%s) | sed "s/:/%s/; s/:/%s 󰳟  /"]],
            helpers.rg_default_opts,
            query,
            fzf_utils.git_files(opts.git_dir),
            utils.nbsp,
            utils.nbsp
          )
          .. "@"
      )
    end,
    before_fzf = helpers.set_custom_keymaps_for_fzf_preview,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local filepath = get_filepath_from_selection()
        vim.fn.setreg("+", filepath)
      end,
      ["ctrl-w"] = function()
        local filepath = get_filepath_from_selection()
        vim.cmd(string.format([[vsplit %s]], filepath))
      end,
      ["ctrl-t"] = function()
        local filepath = get_filepath_from_selection()
        vim.cmd(string.format([[tabnew %s]], filepath))
      end,
    }),
    fzf_extra_args = "--with-nth=1,3.. " -- Hide line number
      .. string.format(
        "--preview-window='%s,%s'",
        helpers.fzf_default_preview_window_args,
        fzf_utils.fzf_initial_preview_scroll_offset("{2}", { fixed_header = 4 })
      ),
  })
end

return M
