local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")

M.git_status = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = fzf_utils.get_git_toplevel(),
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

    utils.sort_filepaths(entries, function(e) return e:sub(4) end)

    entries = utils.map(entries, function(_, e)
      local status = e:sub(1, 2)
      local filename = e:sub(4)

      if status == "??" then status = " ?" end

      -- TODO: status coloring
      local status_first = status:sub(1, 1)
      local status_second = status:sub(2, 2)
      status = string.format(
        [[%s %s]],
        utils.ansi_codes.blue(status_first),
        status_second == "D" and utils.ansi_codes.red("D")
          or utils.ansi_codes.yellow(status_second)
      )

      return string.format("%s%s%s", status, utils.nbsp, filename)
    end)

    return entries
  end

  local entries = get_entries()

  local _, fzf_initial_pos = utils.find(
    entries,
    function(e)
      return vim.split(e, utils.nbsp)[2]
        == fzf_utils.get_filepath_from_git_root(vim.fn.expand("%"))
    end
  )
  if fzf_initial_pos == nil then fzf_initial_pos = 0 end

  if config.debug then
    vim.notify(string.format([[Fzf initial pos: %d]], fzf_initial_pos))
  end

  core.fzf(table.concat(entries, "\n"), function(selection)
    local filepath = vim.split(selection[1], utils.nbsp)[2]

    local parts = vim.split(filepath, " -> ") -- In case if file is renamed
    if #parts > 1 then filepath = parts[2] end

    vim.cmd(
      string.format(
        [[e %s]],
        fzf_utils.convert_git_filepath_to_fullpath(filepath, opts.git_dir)
      )
    )
  end, {
    fzf_preview_cmd = nil,
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "GitStatus",
    fzf_initial_position = fzf_initial_pos,
    fzf_binds = {
      ["left"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local filepath = vim.split(current_selection, utils.nbsp)[2]

        local parts = vim.split(filepath, " -> ") -- In case if file is renamed
        if #parts > 1 then filepath = parts[2] end

        local cmd = string.format(
          [[git add %s]],
          fzf_utils.convert_git_filepath_to_fullpath(filepath, opts.git_dir)
        )
        if config.debug then vim.notify(string.format([[Running: %s]], cmd)) end
        vim.fn.system(cmd)
        core.send_to_fzf(
          string.format(
            "track+reload(%s)",
            string.format(
              [[cat <<EOF
%s
EOF]],
              table.concat(get_entries(), "\n")
            )
          )
        )
      end,
      ["right"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local filepath = vim.split(current_selection, utils.nbsp)[2]

        local parts = vim.split(filepath, " -> ") -- In case if file is renamed
        if #parts > 1 then filepath = parts[2] end

        local cmd = string.format(
          [[git restore --staged %s]],
          fzf_utils.convert_git_filepath_to_fullpath(filepath, opts.git_dir)
        )
        if config.debug then vim.notify(string.format([[Running: %s]], cmd)) end
        vim.fn.system(cmd)
        core.send_to_fzf(
          string.format(
            "track+reload(%s)",
            string.format(
              [[cat <<EOF
%s
EOF]],
              table.concat(get_entries(), "\n")
            )
          )
        )
      end,
      ["ctrl-y"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local filepath = vim.split(current_selection, utils.nbsp)[2]

        local parts = vim.split(filepath, " -> ") -- In case if file is renamed
        if #parts > 1 then filepath = parts[2] end

        filepath =
          fzf_utils.convert_git_filepath_to_fullpath(filepath, opts.git_dir)

        vim.fn.setreg("+", filepath)
        vim.notify(string.format([[Copied to clipboard: %s]], filepath))
      end,
    },
    fzf_on_focus = function(selection)
      local args = vim.split(selection, utils.nbsp, { trimpempty = false })
      local status = args[1]
      local filepath = args[2]

      local parts = vim.split(filepath, " -> ") -- In case if file is renamed
      if #parts > 1 then filepath = parts[2] end

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

      core.send_to_fzf(
        string.format(
          [[change-preview:%s]],
          true
              and (not renamed and string.format(
                "%s diff --color %s %s/%s | delta %s",
                git,
                is_fully_staged and "--staged"
                  or (
                    (added or is_untracked) and "--no-index /dev/null"
                    or (deleted and "--cached -- " or "")
                  ),
                opts.git_dir,
                filepath,
                config.delta_default_opts
              ) or string.format(
                [[bat %s %s]],
                config.bat_default_opts,
                fzf_utils.convert_git_filepath_to_fullpath(
                  filepath,
                  opts.git_dir
                )
              ))
            or string.format( -- Much slower due to `script`?
              "%s %s -c core.pager='delta' diff --staged %s/[2]",
              fzf_utils.like_tty,
              git,
              opts.git_dir,
              filepath
            )
        )
      )
    end,
  })
end

M.git_commits = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = fzf_utils.get_git_toplevel(),
    filepaths = "",
  }, opts or {})

  local git_format = "%C(blue)%h%Creset" -- Hash. In blue
    .. utils.nbsp
    .. "%C(white)%s%Creset" -- Subject
    -- .. utils.nbsp
    -- .. "%cr%<|(12)" -- Date. Right-aligned. Truncates-right to 12
    -- .. utils.nbsp
    -- .. "%an" -- Author
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

  local entries = get_entries()

  core.fzf(table.concat(entries, "\n"), function(selection)
    local commit_hash = vim.split(selection[1], utils.nbsp)[1]

    vim.notify(commit_hash)
  end, {
    fzf_preview_cmd = string.format(
      [[git -C %s show --color {1} %s | delta %s]],
      opts.git_dir,
      opts.filepaths ~= "" and string.format("-- %s", opts.filepaths) or "",
      config.delta_default_opts
    ),
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "GitCommits",
    fzf_initial_position = 1,
    fzf_binds = {
      ["ctrl-y"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local commit_hash = vim.split(current_selection, utils.nbsp)[1]

        vim.fn.setreg("+", commit_hash)
        vim.notify(string.format([[Copied to clipboard: %s]], commit_hash))
      end,
    },
  })
end

M.git_stash = function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = fzf_utils.get_git_toplevel(),
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

      return string.format(
        "%s%s%s",
        utils.ansi_codes.blue(parts[1]),
        utils.nbsp,
        utils.ansi_codes.white(parts[2])
      )
    end)
    return stash
  end

  local entries = get_entries()
  vim.notify(table.concat(entries, "\n"))

  core.fzf(table.concat(entries, "\n"), function(selection)
    local stash_ref = vim.split(selection[1], utils.nbsp)[1]

    vim.notify(stash_ref)
  end, {
    fzf_preview_cmd = string.format(
      [[git -C %s stash show --full-index --color {1} | delta %s]],
      opts.git_dir,
      config.delta_default_opts
    ),
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "GitStash",
    fzf_initial_position = 1,
    fzf_binds = {
      ["ctrl-y"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local stash_ref = vim.split(current_selection, utils.nbsp)[1]

        vim.fn.setreg("+", stash_ref)
        vim.notify(string.format([[Copied to clipboard: %s]], stash_ref))
      end,
    },
  })
end

M.git_submodules = function(on_submodule)
  local submodules =
    vim.fn.systemlist([[git submodule --quiet foreach 'echo $path']])
  submodules = utils.map(submodules, function(_, e) return vim.trim(e) end)

  core.fzf(table.concat(submodules, "\n"), function(selection)
    local submodule_path = selection[1]
    on_submodule(fzf_utils.get_git_toplevel() .. "/" .. submodule_path)
  end, {
    fzf_preview_cmd = nil,
    fzf_extra_args = "--with-nth=1..",
    fzf_prompt = "GitSubmodules",
    fzf_binds = {
      ["ctrl-y"] = function()
        local current_selection = FZF_CURRENT_SELECTION
        local submodule_path = current_selection

        vim.fn.setreg("+", submodule_path)
        vim.notify(string.format([[Copied to clipboard: %s]], submodule_path))
      end,
    },
  })
end

return M
