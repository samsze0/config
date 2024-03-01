local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")

-- Fzf git ref log
--
---@param opts? { git_dir?: string }
return function(opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
  }, opts or {})

  ---@type { sha: string, ref: string, action: string, description: string }[]
  local reflog

  local get_entries = function()
    local result = utils.systemlist("git reflog")

    local entries = {}
    reflog = {}
    for _, line in ipairs(result) do
      local sha, ref, action, description =
        line:match("(%w+) (%w+@{%d+}): ([^:]+): (.+)")
      if sha and ref and action and description then
        table.insert(
          entries,
          fzf_utils.join_by_delim(
            ref,
            utils.ansi_codes.blue(action),
            description
          )
        )
        table.insert(reflog, {
          sha = sha,
          ref = ref,
          action = action,
          description = description,
        })
      else
        vim.warn("Failed to parse git reflog entry", line)
      end
    end
    return entries
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({
      preview_in_terminal_mode = true,
      preview_popup_win_options = { number = false },
    })

  core.fzf(get_entries(), {
    prompt = "Git-Reflog",
    layout = layout,
    main_popup = popups.main,
    binds = {
      ["+before-start"] = function(state)
        helpers.set_keymaps_for_preview_remote_nav(
          popups.main,
          popups.nvim_preview
        )
        helpers.set_keymaps_for_popups_nav({
          { popup = popups.main, key = "<C-s>", is_terminal = true },
          { popup = popups.nvim_preview, key = "<C-f>", is_terminal = false },
        })

        popups.main.border:set_text("bottom", " <y> copy ref ")
      end,
      ["focus"] = function(state)
        local ref = reflog[state.focused_entry_index].ref

        local command = string.format(
          [[git -C %s diff %s | delta %s]],
          opts.git_dir,
          ref,
          helpers.delta_nvim_default_opts
        )

        local reflog = utils.systemlist(command)
        set_preview_content(reflog)
      end,
      ["+select"] = function(state)
        local ref = reflog[state.focused_entry_index].ref

        vim.info(ref)
      end,
      ["ctrl-y"] = function(state)
        local ref = reflog[state.focused_entry_index].ref

        vim.fn.setreg("+", ref)
        vim.info(string.format([[Copied to clipboard: %s]], ref))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "2..",
    }),
  })
end
