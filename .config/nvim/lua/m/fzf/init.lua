local M = {}

local core = require("m.fzf.core")
local config = require("m.fzf.config")
local fzf_utils = require("m.fzf.utils")
local utils = require("m.utils")

M.setup = function(opts) end

M.git_files = function()
  local entries = vim.fn.system(
    string.format(
      [[{ echo "$(%s ls-files --full-name --exclude-standard)"; echo "$(%s ls-files --full-name --others --exclude-standard)"; }]],
      fzf_utils.git_toplevel,
      fzf_utils.git_toplevel
    )
  )
  entries = entries:gsub("\n$", "") -- Remove the extra newline at the end
  core.fzf(
    entries,
    function(selection) vim.notify(table.concat(selection, " ")) end,
    {
      fzf_preview_cmd = string.format(
        "bat %s %s/{}",
        config.bat_default_opts,
        fzf_utils.get_git_toplevel()
      ),
      fzf_on_focus = function(selection)
        vim.notify("Current selection: " .. selection)
      end
    }
  )
end

M.git_status = function()
  local entries = vim.fn.system(string.format(
    [[%s -c color.status=false status -su]], -- Show in short format and show all untracked files
    fzf_utils.git_toplevel
  ))
  entries = entries:gsub("\n$", "") -- Remove the extra newline at the end

  local entries_list = vim.split(entries, "\n")
  entries_list = utils.map(entries_list, function(_, e)
    local status = e:sub(1, 2)
    local filename = e:sub(4)

    -- TODO: status coloring
    local status_first = string.byte(status, 1)
    -- Staged if not space or ? (32 or 63)
    local is_staged = status_first == 32 or status_first == 63

    return string.format(
      "%s%s%s%s%s",
      is_staged and "y" or "n",
      utils.nbsp,
      status,
      utils.nbsp,
      filename
    )
  end)
  entries = table.concat(entries_list, "\n")

  core.fzf(
    entries,
    function(selection) vim.notify(table.concat(selection, " ")) end,
    {
      fzf_preview_cmd = true
          and string.format(
            "%s diff --color --staged %s/{3} | delta --width=$FZF_PREVIEW_COLUMNS %s",
            fzf_utils.git_toplevel,
            fzf_utils.get_git_toplevel(),
            config.delta_default_opts
          )
        or string.format( -- Much slower due to `script`?
          "%s %s -c core.pager='delta' diff --staged %s/{3}",
          fzf_utils.like_tty,
          fzf_utils.git_toplevel,
          fzf_utils.get_git_toplevel()
        ),
      fzf_extra_args = "--with-nth=2..",
    }
  )
end

return M
