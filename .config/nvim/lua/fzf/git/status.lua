local core = require("fzf.core")
local helpers = require("fzf.helpers")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

local git_status = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
  }, opts or {})

  local git = string.format([[git -C %s]], opts.git_dir)

  local function get_entries()
    local entries = vim.fn.systemlist(
      string.format(
        [[%s -c color.status=false status -su]], -- Show in short format and show all untracked files
        git
      ),
      nil,
      false
    )

    entries = utils.sort_by_files(entries, function(e) return e:sub(4) end)

    entries = utils.map(entries, function(_, e)
      local status = e:sub(1, 2)
      local filename = e:sub(4)

      if status == "??" then status = " ?" end

      local status_first = status:sub(1, 1)
      local status_second = status:sub(2, 2)
      status = string.format(
        [[%s %s]],
        utils.ansi_codes.blue(status_first),
        status_second == "D" and utils.ansi_codes.red("D")
          or utils.ansi_codes.yellow(status_second)
      )

      return fzf_utils.create_fzf_entry(status, filename)
    end)

    return entries
  end

  local entries = get_entries()

  local fzf_initial_pos, _ = utils.find(
    entries,
    function(_, e)
      return vim.split(e, utils.nbsp)[2]
        == git_utils.convert_filepath_to_gitpath(vim.fn.expand("%"))
    end
  )
  if fzf_initial_pos == nil then fzf_initial_pos = 0 end

  local get_selection = function()
    local selection = FZF.current_selection

    local args = vim.split(selection, utils.nbsp)
    local filepath = args[2]

    local parts = vim.split(filepath, " -> ") -- In case if file is renamed
    if #parts > 1 then filepath = parts[2] end

    filepath = opts.git_dir .. "/" .. filepath

    return filepath, args[1]
  end

  local win_id = vim.api.nvim_get_current_win()

  core.fzf(entries, {
    fzf_on_select = function()
      local filepath = get_selection()

      jumplist.save(win_id)
      vim.cmd(string.format([[e %s]], filepath))
    end,
    fzf_preview_cmd = nil,
    fzf_extra_args = helpers.fzf_default_args
      .. " --with-nth=1.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
    fzf_prompt = "Git-Status",
    fzf_initial_position = fzf_initial_pos,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["left"] = function()
        local filepath = get_selection()

        vim.fn.system(string.format([[git add %s]], filepath))
        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(get_entries()))
      end,
      ["right"] = function()
        local filepath = get_selection()

        vim.fn.system(string.format([[git restore --staged %s]], filepath))
        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(get_entries()))
      end,
      ["ctrl-y"] = function()
        local filepath = get_selection()

        vim.fn.setreg("+", filepath)
        vim.notify(string.format([[Copied to clipboard: %s]], filepath))
      end,
      ["ctrl-x"] = function()
        local filepath = get_selection()

        vim.fn.system(string.format([[git restore %s]], filepath))
        core.send_to_fzf(fzf_utils.generate_fzf_reload_action(get_entries()))
      end,
    }),
    fzf_on_focus = function()
      local filepath, status = get_selection()

      local status_x = status:sub(1, 1)
      local status_y = status:sub(3, 3)

      local is_fully_staged = status_x == "M" and status_y == " "
      local is_partially_staged = status_x == "M" and status_y == "M"
      local is_untracked = status_y == "?"
      local unstaged = status_x == " " and not is_untracked
      local worktree_clean = status_y == " "

      local added = status_x == "A" and worktree_clean
      local deleted = status_x == "D" and worktree_clean
      local renamed = status_x == "R" and worktree_clean
      local copied = status_x == "C" and worktree_clean
      local type_changed = status_x == "T" and worktree_clean

      local ignored = status_x == "!" and status_y == "!"

      local renamed_preview_cmd =
        string.format([[bat %s %s]], helpers.bat_default_opts, filepath)

      core.send_to_fzf(
        string.format(
          [[change-preview:%s]],
          renamed and renamed_preview_cmd
            or string.format(
              "%s diff --color %s %s | delta %s",
              git,
              is_fully_staged and "--staged"
                or (
                  (added or is_untracked) and "--no-index /dev/null"
                  or (deleted and "--cached -- " or "")
                ),
              filepath,
              helpers.delta_default_opts
            )
        )
      )
    end,
  })
end

return git_status
