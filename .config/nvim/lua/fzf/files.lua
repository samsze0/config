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
    git_dir = fzf_utils.get_git_toplevel(),
  }, opts or {})

  local git = string.format([[git -C %s]], opts.git_dir)

  local entries =
    vim.fn.systemlist(fzf_utils.git_files(opts.git_dir), nil, false)
  entries = utils.filter(entries, function(e) return e ~= "" end)

  utils.sort_filepaths(entries, function(e) return e end)

  local fzf_preview_cmd =
    string.format("bat %s %s/{}", config.bat_default_opts, opts.git_dir)
  local fallback_to_bat = false

  core.fzf(
    entries,
    function(selection)
      vim.cmd(
        string.format(
          [[e %s]],
          fzf_utils.convert_git_filepath_to_fullpath(selection[1], opts.git_dir)
        )
      )
    end,
    {
      fzf_preview_cmd = not opts.nvim_preview and fzf_preview_cmd or nil,
      fzf_prompt = "Files",
      fzf_on_focus = opts.nvim_preview
          and function(selection)
            local filepath = fzf_utils.convert_git_filepath_to_fullpath(
              selection,
              opts.git_dir
            )

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
            fzf_utils.convert_git_filepath_to_fullpath(
              current_selection,
              opts.git_dir
            )
          )
          vim.notify(
            string.format(
              [[Copied %s to clipboard]],
              fzf_utils.convert_git_filepath_to_fullpath(
                current_selection,
                opts.git_dir
              )
            )
          )
        end,
        ["ctrl-w"] = function()
          local current_selection = FZF_CURRENT_SELECTION
          vim.cmd(
            string.format(
              [[vsplit %s]],
              fzf_utils.convert_git_filepath_to_fullpath(
                current_selection,
                opts.git_dir
              )
            )
          )
          vim.api.nvim_win_close(FZF_WINDOW, true)
        end,
        ["ctrl-t"] = function()
          local current_selection = FZF_CURRENT_SELECTION
          vim.cmd(
            string.format(
              [[tabnew %s]],
              fzf_utils.convert_git_filepath_to_fullpath(
                current_selection,
                opts.git_dir
              )
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
