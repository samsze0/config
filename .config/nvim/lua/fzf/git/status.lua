local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

-- Fzf git status
--
---@param opts? { git_dir?: string }
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

    if vim.v.shell_error ~= 0 then
      vim.error("Error getting git status")
      return {}
    end

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

      return fzf_utils.join_by_delim(status, filename)
    end)

    return entries
  end

  local entries = get_entries()

  local pos, _ = utils.find(
    entries,
    function(_, e)
      return vim.split(e, utils.nbsp)[2]
        == git_utils.convert_filepath_to_gitpath(vim.fn.expand("%"))
    end
  )
  if pos == nil then pos = 0 end

  ---@param entry string
  ---@return string, { status: string, status_x: string, status_y: string, is_fully_staged: boolean, is_partially_staged: boolean, is_untracked: boolean, unstaged: boolean, worktree_clean: boolean, added: boolean, deleted: boolean, renamed: boolean, copied: boolean, type_changed: boolean, ignored: boolean, has_merge_conflicts: boolean }, string
  local parse_entry = function(entry)
    local args = vim.split(entry, utils.nbsp)
    local gitpath = args[2]
    local status = args[1]

    local status_x = status:sub(1, 1)
    local status_y = status:sub(3, 3)

    local is_fully_staged = status_x == "M" and status_y == " "
    local is_partially_staged = status_x == "M" and status_y == "M"
    local is_untracked = status_y == "?"
    local unstaged = status_x == " " and not is_untracked
    local has_merge_conflicts = status_x == "U"

    local worktree_clean = status_y == " "

    local added = status_x == "A" and worktree_clean
    local deleted = status_x == "D" and worktree_clean
    local renamed = status_x == "R" and worktree_clean
    local copied = status_x == "C" and worktree_clean
    local type_changed = status_x == "T" and worktree_clean

    local ignored = status_x == "!" and status_y == "!"

    local parts = vim.split(gitpath, " -> ") -- In case if file is renamed
    if #parts > 1 then gitpath = parts[2] end

    local filepath = opts.git_dir .. "/" .. gitpath

    return filepath,
      {
        status = status,
        status_x = status_x,
        status_y = status_y,
        is_fully_staged = is_fully_staged,
        is_partially_staged = is_partially_staged,
        is_untracked = is_untracked,
        unstaged = unstaged,
        worktree_clean = worktree_clean,
        added = added,
        deleted = deleted,
        renamed = renamed,
        copied = copied,
        type_changed = type_changed,
        ignored = ignored,
        has_merge_conflicts = has_merge_conflicts,
      },
      gitpath
  end

  local win = vim.api.nvim_get_current_win()

  core.fzf(entries, {
    prompt = "Git-Status",
    initial_position = pos,
    binds = vim.tbl_extend("force", helpers.default_fzf_keybinds, {
      ["focus"] = function(state)
        local filepath, status = parse_entry(state.focused_entry)

        if status.renamed then
          core.send_to_fzf(
            string.format(
              [[change-preview:%s]],
              string.format([[bat %s %s]], helpers.bat_default_opts, filepath)
            )
          )
        else
          core.send_to_fzf(
            string.format(
              [[change-preview:%s]],
              string.format(
                "%s diff --color %s %s | delta %s",
                git,
                status.is_fully_staged and "--staged"
                  or (
                    (status.added or status.is_untracked)
                      and "--no-index /dev/null"
                    or (status.deleted and "--cached -- " or "")
                  ),
                filepath,
                helpers.delta_default_opts
              )
            )
          )
        end
      end,
      ["+select"] = function(state)
        local filepath, status, gitpath = parse_entry(state.focused_entry)

        if status.has_merge_conflicts then
          local ours = vim.fn.systemlist(
            string.format([[git -C %s show :2:%s]], opts.git_dir, gitpath)
          )
          if vim.v.shell_error ~= 0 then
            vim.error(
              string.format(
                [[Error getting ours version of file: %s]],
                filepath
              )
            )
            return
          end
          local theirs = vim.fn.systemlist(
            string.format([[git -C %s show :3:%s]], opts.git_dir, gitpath)
          )
          if vim.v.shell_error ~= 0 then
            vim.error(
              string.format(
                [[Error getting theirs version of file: %s]],
                filepath
              )
            )
            return
          end

          local filename = vim.fn.fnamemodify(filepath, ":t")
          local ft = vim.filetype.match({
            filename = filename,
            contents = vim.fn.readfile(filepath),
          })

          local buffers = utils.show_diff({
            filetype = ft,
            cursor_at = 2,
          }, {
            filepath_or_content = ours,
            readonly = true,
          }, {
            filepath_or_content = filepath,
            readonly = false,
          }, {
            filepath_or_content = theirs,
            readonly = true,
          })
          vim.api.nvim_tabpage_set_var(0, "diff_buffers", buffers)
          return
        end

        jumplist.save(win)
        vim.cmd(string.format([[e %s]], filepath))
      end,
      ["left"] = function(state)
        local filepath = parse_entry(state.focused_entry)

        vim.fn.system(string.format([[git add %s]], filepath))
        core.send_to_fzf(fzf_utils.reload_action(get_entries()))
      end,
      ["right"] = function(state)
        local filepath = parse_entry(state.focused_entry)

        vim.fn.system(string.format([[git restore --staged %s]], filepath))
        core.send_to_fzf(fzf_utils.reload_action(get_entries()))
      end,
      ["ctrl-y"] = function(state)
        local filepath = parse_entry(state.focused_entry)

        vim.fn.setreg("+", filepath)
        vim.info(string.format([[Copied to clipboard: %s]], filepath))
      end,
      ["ctrl-x"] = function(state)
        local filepath, status = parse_entry(state.focused_entry)

        if status.has_merge_conflicts then
          vim.error(
            string.format(
              [[Cannot restore/delete file with merge conflicts: %s]],
              filepath
            )
          )
          return
        end

        vim.fn.system(string.format([[git restore %s]], filepath))
        if vim.v.shell_error ~= 0 then
          vim.fn.system(string.format([[rm %s]], filepath))
          if vim.v.shell_error ~= 0 then
            vim.error(
              string.format([[Error restoring/deleting file: %s]], filepath)
            )
          end
        end
        core.send_to_fzf(fzf_utils.reload_action(get_entries()))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
      ["--preview-window"] = helpers.fzf_default_preview_window_args,
    }),
  })
end

return git_status
