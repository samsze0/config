local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")

-- Fzf git stash
--
---@param opts? { git_dir?: string }
local git_stash = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
  }, opts or {})

  local get_entries = function()
    local stash =
      vim.fn.systemlist(string.format([[git -C %s stash list]], opts.git_dir))

    if vim.v.shell_error ~= 0 then
      vim.error("Error getting git stash")
      return {}
    end

    stash = utils.map(stash, function(_, e)
      local parts = utils.split_string_n(e, 1, ":")

      parts = utils.map(parts, function(_, p) return vim.trim(p) end)

      return fzf_utils.join_by_delim(
        utils.ansi_codes.blue(parts[1]),
        utils.ansi_codes.white(parts[2])
      )
    end)
    return stash
  end

  local parse_entry = function(entry)
    local args = vim.split(entry, utils.nbsp)
    return unpack(args)
  end

  core.fzf(get_entries(), {
    prompt = "Git-Stash",
    initial_position = 1,
    preview_cmd = string.format(
      [[git -C %s stash show --full-index --color {1} | delta %s]],
      opts.git_dir,
      helpers.delta_default_opts
    ),
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["+select"] = function(state)
        local stash_ref = parse_entry(state.focused_entry)

        vim.info(stash_ref)
      end,
      ["ctrl-y"] = function(state)
        local stash_ref = parse_entry(state.focused_entry)

        vim.fn.setreg("+", stash_ref)
        vim.info(string.format([[Copied to clipboard: %s]], stash_ref))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
      ["--preview-window"] = helpers.fzf_default_preview_window_args,
    }),
  })
end

return git_stash
