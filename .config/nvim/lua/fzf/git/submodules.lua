local core = require("fzf.core")
local helpers = require("fzf.helpers")
local fzf_utils = require("fzf.utils")
local utils = require("utils")
local git_utils = require("utils.git")

-- Fzf all git submodules
--
---@param on_submodule function
local git_submodules = function(on_submodule)
  local submodules =
    vim.fn.systemlist([[git submodule --quiet foreach 'echo $path']])

  if vim.v.shell_error ~= 0 then
    vim.error("Error fetching git submodules", table.concat(submodules, "\n"))
    return
  end

  submodules = utils.map(submodules, function(_, e) return vim.trim(e) end)

  local git_dir = git_utils.current_git_dir()

  local function parse_entry(entry)
    local submodule_path = entry
    submodule_path = git_dir .. "/" .. submodule_path

    return submodule_path
  end

  local layout, popups, set_preview_content =
    helpers.create_nvim_preview_layout({ preview_in_terminal_mode = true })

  core.fzf(submodules, {
    prompt = "Git-Submodules",
    layout = layout,
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
      end,
      ["focus"] = function(state)
        local submodule_path = parse_entry(state.focused_entry)

        popups.nvim_preview.border:set_text(
          "top",
          " " .. git_utils.convert_filepath_to_gitpath(submodule_path) .. " "
        )

        local output = vim.fn.systemlist(
          string.format("git -C %s log --color --decorate", submodule_path)
        )
        if vim.v.shell_error ~= 0 then
          vim.error(
            "Error getting git commits for current HEAD of git submodule",
            submodule_path,
            table.concat(output, "\n")
          )
          return
        end

        set_preview_content(output)
      end,
      ["+select"] = function(state)
        local submodule_path = parse_entry(state.focused_entry)
        on_submodule(submodule_path)
      end,
      ["ctrl-y"] = function(state)
        local submodule_path = parse_entry(state.focused_entry)

        vim.fn.setreg("+", submodule_path)
        vim.info(string.format([[Copied to clipboard: %s]], submodule_path))
      end,
    },
    extra_args = vim.tbl_extend("force", helpers.fzf_default_args, {
      ["--with-nth"] = "1..",
    }),
  })
end

return git_submodules
