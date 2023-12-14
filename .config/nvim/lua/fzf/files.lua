local M = {}

local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")

-- TODO: no-git mode
M.files = function(opts)
  opts = vim.tbl_extend("force", {
    nvim_preview = false,
    git_dir = fzf_utils.get_git_toplevel(),
  }, opts or {})

  local get_relpath_from_selection = function()
    local selection = FZF_STATE.current_selection

    return fzf_utils.convert_gitpath_to_relpath(selection, opts.git_dir)
  end

  local entries =
    vim.fn.systemlist(fzf_utils.git_files(opts.git_dir), nil, false)
  entries = utils.filter(entries, function(e) return e ~= "" end)

  utils.sort_filepaths(entries, function(e) return e end)

  local fzf_preview_cmd =
    string.format("bat %s %s/{}", helpers.bat_default_opts, opts.git_dir)

  core.fzf(entries, {
    fzf_preview_cmd = not opts.nvim_preview and fzf_preview_cmd or nil,
    fzf_prompt = "Files",
    fzf_on_select = function()
      local filepath = get_relpath_from_selection()
      vim.cmd(string.format([[e %s]], filepath))
    end,
    before_fzf = function()
      helpers.set_custom_keymaps_for_nvim_preview()
      helpers.set_custom_keymaps_for_fzf_preview()
    end,
    fzf_on_focus = opts.nvim_preview
        and function()
          local path = get_relpath_from_selection()

          local filename = vim.fn.fnamemodify(path, ":t")
          local ft = vim.filetype.match({ filename = filename })
          local is_binary =
            vim.fn.system("file --mime " .. path):match("charset=binary")

          if not is_binary then
            vim.api.nvim_buf_set_lines(
              FZF_STATE.preview_buffer,
              0,
              -1,
              false,
              vim.fn.readfile(path)
            )
            vim.api.nvim_buf_set_option(
              FZF_STATE.preview_buffer,
              "filetype",
              ft
            )

            -- Switch to preview window and back in order to refresh scrollbar
            -- TODO: Remove this once scrollbar plugin support remote refresh
            vim.api.nvim_set_current_win(FZF_STATE.preview_window)
            vim.api.nvim_set_current_win(FZF_STATE.window)
          else
            vim.api.nvim_buf_set_lines(
              FZF_STATE.preview_buffer,
              0,
              -1,
              false,
              { "No preview available" }
            )
          end
        end
      or nil,
    fzf_binds = vim.tbl_extend("force", helpers.custom_fzf_keybinds, {
      ["ctrl-y"] = function()
        local path = get_relpath_from_selection()
        vim.fn.setreg("+", path)
        vim.notify(string.format([[Copied %s to clipboard]], path))
      end,
      ["ctrl-w"] = function()
        local path = get_relpath_from_selection()
        core.abort_and_execute(
          function() vim.cmd(string.format([[vsplit %s]], path)) end
        )
      end,
      ["ctrl-t"] = function()
        local path = get_relpath_from_selection()
        core.abort_and_execute(
          function() vim.cmd(string.format([[tabnew %s]], path)) end
        )
      end,
    }),
    nvim_preview = opts.nvim_preview,
    fzf_extra_args = "--with-nth=1.. --preview-window="
      .. helpers.fzf_default_preview_window_args,
  })
end

return M
