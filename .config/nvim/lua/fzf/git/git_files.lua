local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local layouts = require("fzf.layouts")
local uv_utils = require("utils.uv")
local git_utils = require("utils.git")
local jumplist = require("jumplist")

-- Fzf a list of git files
--
---@param ref string
---@param opts? { git_dir?: string, parent_state?: string }
return function(ref, opts)
  opts = vim.tbl_extend("force", {
    git_dir = git_utils.current_git_dir(),
  }, opts or {})

  local current_win = vim.api.nvim_get_current_win()

  local layout, popups, set_preview_content, binds =
    layouts.create_nvim_diff_preview_layout({
      preview_popups_win_options = {},
    })

  local parse_entry = function(entry) return entry, opts.git_dir .. "/" .. entry end

  local git_files = utils.systemlist(
    string.format(
      "git -C %s show --pretty=format: --name-only %s",
      opts.git_dir,
      ref
    ),
    {
      keepempty = false,
    }
  )

  core.fzf(git_files, {
    prompt = "Git-Files",
    layout = layout,
    main_popup = popups.main,
    binds = fzf_utils.bind_extend(binds, {
      ["+before-start"] = function(state)
        popups.main.border:set_text(
          "bottom",
          " <select> goto file | <y> copy path "
        )
      end,
      ["focus"] = function(state)
        local git_file, filepath = parse_entry(state.focused_entry)
        local before = utils.systemlist(
          string.format("git cat-file blob %s~1:%s", ref, git_file),
          {
            throw_error = false,
          }
        ) or {}
        local after = utils.systemlist(
          string.format("git cat-file blob %s:%s", ref, git_file)
        )

        local filename = vim.fn.fnamemodify(filepath, ":t")
        local ft = vim.filetype.match({
          filename = filename,
          contents = vim.fn.readfile(filepath),
        })

        set_preview_content(before, after, {
          filetype = ft,
        })
      end,
      ["+select"] = function(state)
        local git_file, filepath = parse_entry(state.focused_entry)

        jumplist.save(current_win)
        vim.cmd("e " .. filepath)
      end,
      ["ctrl-y"] = function(state)
        local git_file, filepath = parse_entry(state.focused_entry)

        vim.fn.setreg("+", filepath)
        vim.info(string.format([[Copied to clipboard: %s]], filepath))
      end,
    }),
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  }, opts.parent_state)
end
