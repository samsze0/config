local utils = require("utils")
local config = require("config")
local timeago = require("utils.timeago")
local actions = require("fzf-lua.actions")

local get_last_word = function(str)
  local parts = vim.split(str, utils.nbsp)
  return parts[#parts]
end

return {
  files = {
    prompt = "GitFiles❯ ",
    cmd = [[{ echo "$(git ls-files --exclude-standard)"; echo "$(git ls-files --others --exclude-standard)"; }]], -- Concat two outputs together
  },
  status = {
    prompt = "GitStatus❯ ",
    cmd = "git -c color.status=false status -su", -- Disable color. Show in short format and show all untracked files.
    previewer = "git_diff",
    preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
    actions = {
      -- actions inherit from 'actions.files' and merge
      ["right"] = { fn = actions.git_unstage, reload = true },
      ["left"] = { fn = actions.git_stage, reload = true },
      ["ctrl-x"] = { fn = actions.git_reset, reload = true },
      ["ctrl-o"] = function(selected, opts)
        local file_path = vim.trim(get_last_word(selected[1]))
        vim.notify(file_path)

        local before_file_content = vim.fn.system(string.format("git show HEAD:%s", file_path))
        local before_file_lines = utils.iter_to_table(before_file_content:gmatch("(.-)\n"))

        utils.open_diff_in_new_tab(before_file_lines, file_path)
      end,
    },
  },
  commits = {
    prompt = "GitLog❯ ",
    -- {1} : commit SHA
    -- <file> : current file

    -- S}how hash (%h) in yellow,
    -- date (%cr) in green, right-aligned and padded to 12 chars w/ %><(12), truncates to 12 if longer w/ %><|(12)
    -- author (%an) in blue
    cmd =
    "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset'",

    -- Show (diff in commit):
    -- commit hash (%H) in red,
    -- author (%an) and email (%ae) in blue,
    -- commit date (%cd) in yellow,
    -- commit subject (first line of commit msg) (%s) in green
    preview = "git show --pretty='%Cred%H%n%Cblue%an <%ae>%n%C(yellow)%cD%n%Cgreen%s' --color {1}",
    preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
    actions = {
      ["default"] = actions.git_checkout,
      ["ctrl-y"] = { fn = actions.git_yank_commit, exec_silent = true },
    },
  },
  bcommits = {
    prompt = "GitLog(File)❯ ",

    -- Show hash (%h) in yellow,
    -- date (%cr) in green, right-aligned and padded to 12 chars w/ %><(12), truncates to 12 if longer w/ %><|(12)
    -- author (%an) in blue
    cmd =
    "git log --color --pretty=format:'%C(yellow)%h%Creset %C(green)(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' <file>",

    -- Show diff between current and <file>:
    -- <hash>^! denotes single commit referred by the hash (^! means to ignore all of its parents)
    preview = "git diff --color {1}^! -- <file>",
    preview_pager = "delta --width=$FZF_PREVIEW_COLUMNS",
    actions = {
      ["default"] = actions.git_buf_edit,
      ["ctrl-w"] = actions.git_buf_vsplit,
      ["ctrl-t"] = actions.git_buf_tabedit,
      ["ctrl-y"] = { fn = actions.git_yank_commit, exec_silent = true },
    },
  },
  branches = {
    prompt = "Branches❯ ",

    cmd = "git branch --all --color",
    -- Show log graph of a branch where each commit is one-liner w/ abbreviated hash (%h)
    preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
    actions = {
      ["default"] = actions.git_switch,
    },
  },
  tags = {
    cmd = "git for-each-ref --color --sort=-taggerdate --format "
        .. "'%(color:yellow)%(refname:short)%(color:reset) "
        .. "%(color:green)(%(taggerdate:relative))%(color:reset)"
        .. " %(subject) %(color:blue)%(taggername)%(color:reset)' refs/tags",
    preview = "git log --graph --color --pretty=format:'%C(yellow)%h%Creset " ..
    "%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' {1}",
    fzf_opts = { ["--no-multi"] = "" },
    actions = { ["default"] = actions.git_checkout },
  },
  stash = {
    prompt = "Stash❯ ",
    cmd = "git --no-pager stash list",
    -- Show in patch format (diff; like `git show`)
    preview = "git --no-pager stash show --patch --color {1}",
    actions = {
      ["default"] = actions.git_stash_apply,
      ["ctrl-x"] = { fn = actions.git_stash_drop, reload = true },
    },
    fzf_opts = {
      ["--no-multi"] = "",
      ["--delimiter"] = "'[:]'",
    },
  },
}
