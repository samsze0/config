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

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_in_terminal_mode = true,
      preview_popup_win_options = { number = false },
    })

  core.fzf(get_entries(), {
    prompt = "Git-Commits",
    layout = layout,
    main_popup = popups.main,
    initial_position = 1, -- TODO: assign to current checkout-ed commit
    binds = fzf_utils.bind_extend(helpers.default_fzf_keybinds, {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
        })

        popups.main.border:set_text("bottom", " <y> copy hash ")
      end,
      ["focus"] = function(state)
        local commit_hash, commit_subject = parse_entry(state.focused_entry)

        popups.nvim_preview.border:set_text("top", " " .. commit_subject .. " ")

        local command = string.format(
          [[git -C %s show --color %s %s | delta %s]],
          opts.git_dir,
          commit_hash,
          opts.filepaths and string.format("-- %s", opts.filepaths) or "",
          helpers.delta_nvim_default_opts
        )

        local output = vim.fn.systemlist(command)
        if vim.v.shell_error ~= 0 then
          vim.error(
            "Error getting details for git commit",
            commit_hash,
            table.concat(output, "\n")
          )
          return
        end

        set_preview_content(output)
      end,
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
    }),
  })
end

return git_commits
