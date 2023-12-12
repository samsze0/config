local M = {}

local core = require("fzf.core")
local config = require("fzf.config")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local filetype = require("plenary").filetype

-- TODO: no-git mode
M.files = function(opts)
  opts = vim.tbl_extend("force", {
    nvim_preview = false,
  }, opts or {})

  local entries = vim.fn.systemlist(fzf_utils.git_files, nil, false)

  utils.sort_filepaths(entries, function(e) return e end)

  local fzf_preview_cmd = string.format(
    "bat %s %s/{}",
    config.bat_default_opts,
    fzf_utils.get_git_toplevel()
  )
  local fallback_to_bat = false

  core.fzf(
    table.concat(entries, "\n"),
    function(selection)
      vim.cmd(
        string.format(
          [[e %s]],
          fzf_utils.convert_git_root_filepath_to_fullpath(selection[1])
        )
      )
    end,
    {
      fzf_preview_cmd = not opts.nvim_preview and fzf_preview_cmd or nil,
      fzf_prompt = "Files",
      fzf_on_focus = opts.nvim_preview
          and function(selection)
            local filepath =
              fzf_utils.convert_git_root_filepath_to_fullpath(selection)

            local ft = filetype.detect(filepath)
            local is_binary =
              vim.fn.system("file --mime " .. filepath):match("charset=binary")

            if fallback_to_bat and ft == "" then
              core.send_to_fzf(
                string.format([[change-preview(%s)]], fzf_preview_cmd)
              )
            end

            if not is_binary then
              vim.api.nvim_buf_set_lines(
                FZF_PREVIEW_BUFFER,
                0,
                -1,
                false,
                vim.fn.readfile(filepath)
              )
              vim.api.nvim_buf_set_option(FZF_PREVIEW_BUFFER, "filetype", ft)

              -- Switch to preview window and back in order to refresh scrollbar
              -- TODO: Remove this once scrollbar plugin support remote refresh
              vim.api.nvim_set_current_win(FZF_PREVIEW_WINDOW)
              vim.api.nvim_set_current_win(FZF_WINDOW)
            else
              vim.api.nvim_buf_set_lines(
                FZF_PREVIEW_BUFFER,
                0,
                -1,
                false,
                { "No preview available" }
              )
            end
          end
        or nil,
      fzf_binds = {
        ["ctrl-y"] = function()
          local current_selection = FZF_CURRENT_SELECTION
          vim.fn.setreg(
            "+",
            fzf_utils.convert_git_root_filepath_to_fullpath(current_selection)
          )
          vim.notify(
            string.format(
              [[Copied %s to clipboard]],
              fzf_utils.convert_git_root_filepath_to_fullpath(current_selection)
            )
          )
        end,
        ["ctrl-w"] = function()
          local current_selection = FZF_CURRENT_SELECTION
          vim.cmd(
            string.format(
              [[vsplit %s]],
              fzf_utils.convert_git_root_filepath_to_fullpath(current_selection)
            )
          )
          vim.api.nvim_win_close(FZF_WINDOW, true)
        end,
        ["ctrl-t"] = function()
          local current_selection = FZF_CURRENT_SELECTION
          vim.cmd(
            string.format(
              [[tabnew %s]],
              fzf_utils.convert_git_root_filepath_to_fullpath(current_selection)
            )
          )
          vim.api.nvim_win_close(FZF_WINDOW, true)
        end,
      },
      nvim_preview = opts.nvim_preview,
    }
  )
end

return M
