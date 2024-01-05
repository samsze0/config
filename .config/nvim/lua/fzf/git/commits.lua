local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

local git_commits = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    filepaths = "",
  }, opts or {})

  local git_format = "%C(blue)%h%Creset" -- Hash. In blue
    .. utils.nbsp
    .. "%C(white)%s%Creset" -- Subject
    .. utils.nbsp
    .. "%D" -- Ref names

  local get_entries = function()
    local commits = vim.fn.systemlist(
      string.format(
        "git -C %s log --oneline --color --pretty=format:'%s' %s",
        opts.git_dir,
        git_format,
        opts.filepaths ~= "" and string.format("-- %s", opts.filepaths) or ""
      )
    )
    return commits
  end

  local get_commit_hash_from_selection = function()
    local selection = FZF.current_selection

    local args = vim.split(selection, utils.nbsp)
    local commit_hash = args[1]

    return commit_hash
  end

  core.fzf(get_entries(), {
    fzf_on_select = function()
      local commit_hash = get_commit_hash_from_selection()

      vim.notify(commit_hash)
    end,
    fzf_preview_cmd = string.format(
      [[git -C %s show --color {1} %s | delta %s]],
      opts.git_dir,
      opts.filepaths ~= "" and string.format("-- %s", opts.filepaths) or "",
      helpers.delta_default_opts
    ),
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
    fzf_prompt = "Git-Commits",
    fzf_initial_position = 1,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local commit_hash = get_commit_hash_from_selection()

        vim.fn.setreg("+", commit_hash)
        vim.notify(string.format([[Copied to clipboard: %s]], commit_hash))
      end,
    }),
  })
end

return git_commits
