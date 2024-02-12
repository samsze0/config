local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local uv_utils = require("utils.uv")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

-- Fzf git status
--
---@param opts? { git_dir?: string, max_num_files?: number }
local git_status = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    max_num_files = 1000,
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

    if #entries > opts.max_num_files then
      vim.error("Too many files to show in git status")
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
  local timer ---@type uv_timer_t?

  local layout, popups, set_preview_content =
    helpers.create_nvim_diff_preview_layout({
      preview_popups_win_options = {},
    })

  core.fzf(entries, {
    prompt = "Git-Status",
    layout = layout,
    main_popup = popups.main,
    initial_position = pos,
    binds = {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_previews.after
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-e>", is_terminal = true },
          {
            popup = popups.nvim_previews.before,
            key = "<C-s>",
            is_terminal = false,
          },
          {
            popup = popups.nvim_previews.after,
            key = "<C-f>",
            is_terminal = false,
          },
        })

        popups.main:map(
          "t",
          "<C-r>",
          function()
            core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
          end
        )
      end,
      ["focus"] = function(state)
        local filepath, status = parse_entry(state.focused_entry)
        local filename = vim.fn.fnamemodify(filepath, ":t")
        local after = vim.fn.readfile(filepath) -- FIX: if deleted or renamed, cannot read file

        if status.renamed then
          local ft = vim.filetype.match({
            filename = filename,
            contents = after,
          })
          set_preview_content(after, after, {
            filetype = ft,
          })
          return
        end

        if status.added or status.is_untracked then
          local ft = vim.filetype.match({
            filename = filename,
            contents = after,
          })
          set_preview_content({}, after, {
            filetype = ft,
          })
          return
        end

        local before = vim.fn.systemlist(
          string.format(
            "git show HEAD:%s",
            git_utils.convert_filepath_to_gitpath(filepath)
          )
        )
        if vim.v.shell_error ~= 0 then
          vim.error(
            "Error getting git file diff content for",
            filepath,
            table.concat(before, "\n")
          )
          return
        end

        local staged = vim.fn.systemlist(
          string.format(
            "git show :%s",
            git_utils.convert_filepath_to_gitpath(filepath)
          )
        )
        if vim.v.shell_error ~= 0 then
          vim.error(
            "Error getting git file diff content for",
            filepath,
            table.concat(staged, "\n")
          )
          return
        end

        if status.deleted then
          local ft = vim.filetype.match({
            filename = filename,
            contents = before,
          })
          set_preview_content(before, {}, {
            filetype = ft,
          })
          return
        end

        if status.is_fully_staged then
          local ft = vim.filetype.match({
            filename = filename,
            contents = after,
          })
          set_preview_content(before, after, {
            filetype = ft,
          })
          return
        end

        local ft = vim.filetype.match({
          filename = filename,
          contents = after,
        })
        set_preview_content(staged, after, {
          filetype = ft,
        })
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
                filepath,
                table.concat(ours, "\n")
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
                filepath,
                table.concat(theirs, "\n")
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

        local output = vim.fn.system(string.format([[git add %s]], filepath))
        if vim.v.shell_error ~= 0 then
          vim.error("Error staging file", filepath, output)
        end
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
      ["right"] = function(state)
        local filepath = parse_entry(state.focused_entry)

        local output =
          vim.fn.system(string.format([[git restore --staged %s]], filepath))
        if vim.v.shell_error ~= 0 then
          vim.error("Error restoring staged file", filepath, output)
        end
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
      ["ctrl-y"] = function(state)
        local filepath = parse_entry(state.focused_entry)

        vim.fn.setreg("+", filepath)
        vim.info(string.format([[Copied to clipboard: %s]], filepath))
      end,
      ["ctrl-x"] = function(state)
        local filepath, status = parse_entry(state.focused_entry)

        if status.has_merge_conflicts then
          vim.error("Cannot restore/delete file with merge conflicts", filepath)
          return
        end

        vim.fn.system(string.format([[git restore %s]], filepath))
        if vim.v.shell_error ~= 0 then
          local output = vim.fn.system(string.format([[rm %s]], filepath))
          if vim.v.shell_error ~= 0 then
            vim.error("Error restoring/deleting file", filepath, output)
          end
        end
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end

return git_status
