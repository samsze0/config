local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local layouts = require("fzf.layouts")
local git_utils = require("utils.git")
local git_commits = require("fzf.git.commits")

-- Fzf all git branches
--
---@param opts? { git_dir?: string, fetch_in_advance?: boolean }
return function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
    fetch_in_advance = false,
  }, opts or {})

  if opts.fetch_in_advance then
    utils.system(string.format("git -C %s fetch", opts.git_dir))
  end

  local initial_pos

  local get_entries = function()
    ---@type string[]
    local branches =
      utils.systemlist(string.format("git -C %s branch --all", opts.git_dir))

    branches = utils.map(branches, function(i, b)
      local branch = b:sub(3)

      -- Handle tracking information
      local parts = vim.split(branch, "->")
      if #parts > 1 then branch = parts[1] end

      local is_current = b:sub(1, 2) == "* "
      if is_current then initial_pos = i end
      local is_remote_branch = b:sub(1, 2) == "  "
        and b:len() > 10
        and b:sub(3, 10) == "remotes/"

      local color = not is_remote_branch and utils.ansi_codes.grey
        or function(...) return ... end

      return fzf_utils.join_by_delim(color(branch))
    end)

    return branches
  end

  local parse_entry = function(entry)
    local args = vim.split(entry, utils.nbsp)
    return unpack(args)
  end

  local layout, popups, set_preview_content, binds =
    layouts.create_nvim_preview_layout({ preview_in_terminal_mode = true })

  core.fzf(get_entries(), {
    prompt = "Git-Branches",
    layout = layout,
    main_popup = popups.main,
    initial_position = initial_pos,
    binds = fzf_utils.bind_extend(binds, {
      ["+before-start"] = function(state)
        popups.main.border:set_text(
          "bottom",
          " <select> checkout | <y> copy branch name | <x> delete | <l> fzf commits "
        )
      end,
      ["focus"] = function(state)
        local branch = parse_entry(state.focused_entry)

        popups.nvim_preview.border:set_text("top", " " .. branch .. " ")

        local log = utils.systemlist(
          string.format(
            "git -C %s log --color --decorate %s",
            opts.git_dir,
            branch
          )
        )
        set_preview_content(log)
      end,
      ["+select"] = function(state)
        local branch = parse_entry(state.focused_entry)

        utils.system(
          string.format("git -C %s checkout %s", opts.git_dir, branch)
        )
        vim.info(string.format([[Checked out branch: %s]], branch))
      end,
      ["ctrl-y"] = function(state)
        local branch = parse_entry(state.focused_entry)

        vim.fn.setreg("+", branch)
        vim.info(string.format([[Copied to clipboard: %s]], branch))
      end,
      ["ctrl-x"] = function(state)
        local branch = parse_entry(state.focused_entry)

        utils.system(
          string.format("git -C %s branch -D %s", opts.git_dir, branch)
        )
        core.send_to_fzf(state.id, fzf_utils.reload_action(get_entries()))
      end,
      ["ctrl-l"] = function(state)
        local branch = parse_entry(state.focused_entry)

        git_commits({
          git_dir = opts.git_dir,
          parent_state = state.id,
          branch = branch,
        })
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end
