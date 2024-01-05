local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

local git_stash = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
  }, opts or {})

  local get_entries = function()
    local stash =
      vim.fn.systemlist(string.format([[git -C %s stash list]], opts.git_dir))
    stash = utils.map(stash, function(_, e)
      local parts = utils.split_string_n(e, 1, ":")
      if not parts then
        vim.notify(string.format([[Invalid stash entry: %s]], e))
        return nil
      end

      parts = utils.map(parts, function(_, p) return vim.trim(p) end)

      return fzf_utils.create_fzf_entry(
        utils.ansi_codes.blue(parts[1]),
        utils.ansi_codes.white(parts[2])
      )
    end)
    return stash
  end

  local get_stash_ref_from_selection = function()
    local selection = FZF.current_selection

    local args = vim.split(selection, utils.nbsp)
    local stash_ref = args[1]

    return stash_ref
  end

  core.fzf(get_entries(), {
    fzf_on_select = function()
      local stash_ref = get_stash_ref_from_selection()

      vim.notify(stash_ref)
    end,
    fzf_preview_cmd = string.format(
      [[git -C %s stash show --full-index --color {1} | delta %s]],
      opts.git_dir,
      helpers.delta_default_opts
    ),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
    fzf_prompt = "Git-Stash",
    fzf_initial_position = 1,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local stash_ref = get_stash_ref_from_selection()

        vim.fn.setreg("+", stash_ref)
        vim.notify(string.format([[Copied to clipboard: %s]], stash_ref))
      end,
    }),
  })
end

return git_stash
