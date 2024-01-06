local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

-- Fzf all git commits
--
-- If filepaths is nil, then all commits are shown, otherwise only those commits that
-- affect the given filepaths are shown.
--
---@param opts? { git_dir?: string, filepaths?: string }
local git_commits = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    filepaths = nil,
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
        opts.filepaths and string.format("-- %s", opts.filepaths) or ""
      )
    )
    if vim.v.shell_error ~= 0 then
      vim.error("Error getting git commits")
      return {}
    end
    return commits
  end

  local parse_entry = function(entry)
    local args = vim.split(entry, utils.nbsp)
    return unpack(args)
  end

  core.fzf(get_entries(), {
    prompt = "Git-Commits",
    preview_cmd = string.format(
      [[git -C %s show --color {1} %s | delta %s]],
      opts.git_dir,
      opts.filepaths and string.format("-- %s", opts.filepaths) or "",
      helpers.delta_default_opts
    ),
    initial_position = 1,
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["+select"] = function(state)
        local commit_hash = parse_entry(state.focused_entry)

        vim.info(commit_hash)
      end,
      ["ctrl-y"] = function(state)
        local commit_hash = parse_entry(state.focused_entry)

        vim.fn.setreg("+", commit_hash)
        vim.info(string.format([[Copied to clipboard: %s]], commit_hash))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
      ["--preview-window"] = helpers.fzf_default_preview_window_args,
    }),
  })
end

return git_commits
